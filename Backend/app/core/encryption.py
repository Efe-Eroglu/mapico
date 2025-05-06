from cryptography.fernet import Fernet
from app.core.config import settings

class EncryptionService:
    def __init__(self, key: bytes):
        self.fernet = Fernet(key)

    def encrypt(self, plaintext: str) -> str:
        token = self.fernet.encrypt(plaintext.encode())
        return token.decode()

    def decrypt(self, token: str) -> str:
        data = self.fernet.decrypt(token.encode())
        return data.decode()

encryption_service = EncryptionService(settings.ENCRYPTION_KEY.encode())
