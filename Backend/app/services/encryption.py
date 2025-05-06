from app.core.encryption import encryption_service

def encrypt_text(plaintext: str) -> str:
    return encryption_service.encrypt(plaintext)

def decrypt_text(ciphertext: str) -> str:
    return encryption_service.decrypt(ciphertext)
