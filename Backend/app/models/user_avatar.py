from sqlalchemy import Column, Integer, ForeignKey, DateTime, func, UniqueConstraint
from sqlalchemy.orm import relationship
from app.db.base import Base

class UserAvatar(Base):
    __tablename__ = "user_avatars"
    __table_args__ = (
        UniqueConstraint("user_id", name="uq_user_avatar_user"),  # her kullanıcıda 1 aktif avatar
    )

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="users tablosundaki id"
    )
    avatar_id = Column(
        Integer,
        ForeignKey("avatars.id", ondelete="SET NULL"),
        nullable=True,
        comment="avatars tablosundaki seçili avatar parçası id’si"
    )
    selected_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Avatar seçiminin yapıldığı tarih"
    )

    # İsteğe bağlı, ilişki tanımları:
    user = relationship("User", back_populates="avatars")
    avatar = relationship("Avatar")
