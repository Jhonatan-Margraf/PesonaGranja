# ============================================================
# 🚀 API Flask + PyTorch + Ngrok — Predição de Peso de Suínos
# ============================================================

from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
import torch.nn as nn
from PIL import Image
import io
import os
import torchvision.transforms as transforms
import torchvision.models as models
from pyngrok import ngrok, conf

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
print(f"📌 Dispositivo: {DEVICE}")

# ============================================================
# PATHS - AJUSTE AQUI SEUS CAMINHOS
# ============================================================

UPLOAD_FOLDER = r"D:\DriverGoogle\uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

MODELO_PESO_PATH = "modelos/50modelo_peso_suinoOriginal.pth"

# ============================================================
# CARREGAR MODELO RESNET18
# ============================================================

print("🐷 Carregando modelo de predição de peso...")

model = models.resnet18(weights=None)
model.fc = nn.Linear(model.fc.in_features, 1)

try:
    if os.path.exists(MODELO_PESO_PATH):
        state_dict = torch.load(MODELO_PESO_PATH, map_location=DEVICE)
        model.load_state_dict(state_dict)
        print(f"✅ Modelo carregado: {MODELO_PESO_PATH}")
    else:
        print(f"❌ Modelo não encontrado. Usando pesos aleatórios para teste.")
except Exception as e:
    print(f"❌ Erro ao carregar modelo: {e}. Usando pesos aleatórios.")

model = model.to(DEVICE)
model.eval()
print(f"✅ Modelo pronto no dispositivo: {DEVICE}")

# ============================================================
# TRANSFORM
# ============================================================

transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225])
])

# ============================================================
# FUNÇÕES DE PREDIÇÃO
# ============================================================

def predict_weight(model, image_tensor):
    with torch.no_grad():
        output = model(image_tensor)
        return output.item()

def predict_image_weight(image_bytes):
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        return {"error": f"Arquivo não é imagem válida: {str(e)}"}

    img_tensor = transform(image).unsqueeze(0).to(DEVICE)
    peso = predict_weight(model, img_tensor)
    return {"peso_kg": round(peso, 2)}

# ============================================================
# API FLASK
# ============================================================

app = Flask(__name__)
CORS(app)
@app.route("/", methods=["GET"])
def home():
    return "<h1>🐷 API de Predição de Peso de Suínos</h1><p>Use /upload para testar via navegador ou /predict para enviar via app.</p>"

# ------------------- Upload via Navegador -------------------
@app.route("/upload", methods=["GET", "POST"])
def upload():
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Upload de Imagem</title>
        <style>body{{font-family:Arial;max-width:600px;margin:40px auto;text-align:center;}}
        input[type=file]{{margin:20px 0;}}button{{padding:10px 20px;font-size:16px;}}</style>
    </head>
    <body>
        <h1>🐷 Upload de Imagem do Suíno</h1>
        <form method="POST" enctype="multipart/form-data">
            <input type="file" name="file" accept="image/*" required><br>
            <button type="submit">Enviar</button>
        </form>
        {resultado}
    </body>
    </html>
    """
    if request.method == "POST":
        if "file" not in request.files:
            return html.format(resultado="<p style='color:red'>Nenhum arquivo enviado!</p>")
        file = request.files["file"]
        if file.filename == '':
            return html.format(resultado="<p style='color:red'>Nenhum arquivo selecionado!</p>")
        if not file.content_type.startswith("image/"):
            return html.format(resultado="<p style='color:red'>Arquivo não é imagem!</p>")

        try:
            image_bytes = file.read()
            result = predict_image_weight(image_bytes)
            if "error" in result:
                return html.format(resultado=f"<p style='color:red'>{result['error']}</p>")

            peso = result["peso_kg"]
            name, ext = os.path.splitext(file.filename)
            new_filename = f"{name}_peso_{peso:.1f}kg{ext}"
            save_path = os.path.join(UPLOAD_FOLDER, new_filename)
            with open(save_path, "wb") as f:
                f.write(image_bytes)
            return html.format(resultado=f"<div style='margin-top:20px;font-weight:bold;'>⚖️ Peso predito: {peso:.2f} kg</div>")
        except Exception as e:
            return html.format(resultado=f"<p style='color:red'>Erro: {str(e)}</p>")

    return html.format(resultado="")

# ------------------- Endpoint principal -------------------
@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error":"Envie um arquivo usando 'file'"}), 400
    file = request.files["file"]
    if file.filename=='' or not file.content_type.startswith("image/"):
        return jsonify({"error":"Arquivo inválido"}), 400

    try:
        image_bytes = file.read()
        result = predict_image_weight(image_bytes)
        if "error" in result:
            return jsonify(result), 400
        peso = result["peso_kg"]
        return f"Predição de Peso\n\nPeso: {peso:.2f} kg", 200, {
            'Content-Type':'text/plain; charset=utf-8',
            'X-Peso-Predito':f"{peso:.2f}"
        }
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ------------------- JSON endpoint -------------------
@app.route("/predict-json", methods=["POST"])
def predict_json():
    if "file" not in request.files:
        return jsonify({"error":"Envie um arquivo usando 'file'"}),400
    file = request.files["file"]
    try:
        image_bytes = file.read()
        result = predict_image_weight(image_bytes)
        if "error" in result: return jsonify(result),400
        return jsonify({
            "success": True,
            "peso_kg": result["peso_kg"],
            "unidade": "kg",
            "modelo": "ResNet18",
            "arquivo": file.filename
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# ============================================================
# NGROK
# ============================================================

NGROK_TOKEN = "2rv3sOP99V8s5Onjx3V2PTD0LoP_3HutrBirTFVfWFjY9oLei"
if NGROK_TOKEN:
    conf.get_default().auth_token = NGROK_TOKEN
    try:
        public_url = ngrok.connect(5000)
        print(f"🌍 URL pública: {public_url}")
        print(f"📝 Teste: {public_url}/predict")
        print(f"📚 Docs: {public_url}/docs")
    except Exception as e:
        print(f"⚠️ Erro ngrok: {e}")

# ============================================================
# RODAR SERVIDOR
# ============================================================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)