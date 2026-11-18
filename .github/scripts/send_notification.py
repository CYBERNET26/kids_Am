import os
import sys
import json
import urllib.request

def main():
    tag = sys.argv[1] if len(sys.argv) > 1 else "v1.0.1"
    title = sys.argv[2] if len(sys.argv) > 2 else "Nueva versión de Kids Am"
    email = os.environ.get("PARENT_EMAIL", "asm.electronica@gmail.com")

    print(f"Enviando correo a {email} para la versión {tag}...")

    payload = {
        "access_key": "e8d1b228-4447-49f3-8f64-4e4b7b328a8d",
        "to": email,
        "subject": f"📢 [Kids Am] ¡Nueva actualización disponible ({tag})!",
        "from_name": "Kids Am - Aprendizaje Infantil",
        "message": f"""¡Hola Papá / Mamá!

Se encuentra disponible una nueva actualización de Kids Am ({tag}): {title}.

Para instalar la actualización en tu dispositivo sin perder las estrellas ni el progreso:
1. Abre Kids Am en tu teléfono o tablet.
2. Ingresa al Panel Parental (ícono de candado 🔒).
3. En la ventana flotante que aparecerá automáticamente («Actualización disponible»), presiona [Aceptar].

¡La app se actualizará automáticamente en el dispositivo!
"""
    }

    req = urllib.request.Request(
        "https://api.web3forms.com/submit",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json", "User-Agent": "KidsAm-Notifier"}
    )

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            print(f"Respuesta del servicio de correo: {resp.status}")
    except Exception as e:
        print(f"Aviso de envío: {e}")

if __name__ == "__main__":
    main()
