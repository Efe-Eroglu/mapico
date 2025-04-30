from passlib.context import CryptContext

# Bcrypt ile hash’leme
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Düz parola ile hash’lenmiş parolayı karşılaştırır.
    """
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """
    Düz parolayı hash’ler ve döner.
    """
    return pwd_context.hash(password)
