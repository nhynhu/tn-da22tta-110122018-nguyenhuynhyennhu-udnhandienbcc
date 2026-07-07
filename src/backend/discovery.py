"""
UDP Discovery Server
--------------------
Cho phép Flutter app tự động tìm thấy Flask server trên mạng LAN.

Cách hoạt động:
  1. Thread này lắng nghe UDP broadcast trên port 5001
  2. Khi nhận được message "BEETLE_DISCOVER", nó trả về IP + port của Flask server
  3. Flutter gửi broadcast → nhận IP → tự cập nhật baseUrl
"""

import socket
import threading
import json


def get_lan_ip():
    """Lấy IP LAN thực tế của máy (không phải 127.0.0.1)."""
    try:
        # Tạo socket kết nối tới DNS public để lấy IP LAN
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(2)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"


def start_discovery_server(flask_port=5000, discovery_port=5001):
    """
    Chạy UDP server lắng nghe broadcast discovery từ Flutter app.

    Args:
        flask_port: Port của Flask server (mặc định 5000)
        discovery_port: Port UDP để discovery (mặc định 5001)
    """
    def _listener():
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind(("0.0.0.0", discovery_port))

        lan_ip = get_lan_ip()
        print(f" [Discovery] Đang lắng nghe trên UDP port {discovery_port}")
        print(f" [Discovery] IP LAN hiện tại: {lan_ip}")

        while True:
            try:
                data, addr = sock.recvfrom(1024)
                message = data.decode("utf-8").strip()

                if message == "BEETLE_DISCOVER":
                    # Mỗi lần nhận request, lấy lại IP (phòng trường hợp đổi mạng)
                    current_ip = get_lan_ip()
                    response = json.dumps({
                        "service": "beetle_api",
                        "ip": current_ip,
                        "port": flask_port,
                        "url": f"http://{current_ip}:{flask_port}",
                    })
                    sock.sendto(response.encode("utf-8"), addr)
                    print(f" [Discovery] Trả lời {addr[0]} → {current_ip}:{flask_port}")
            except Exception as e:
                print(f" [Discovery] Lỗi: {e}")

    thread = threading.Thread(target=_listener, daemon=True)
    thread.start()
    return thread
