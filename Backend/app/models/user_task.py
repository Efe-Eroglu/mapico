from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class UserTask(Base):
    __tablename__ = "user_tasks"

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
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="CASCADE"),
        nullable=False,
        comment="tasks tablosundaki id"
    )
    completed_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Görevin tamamlandığı zaman"
    )
    score = Column(
        Integer,
        nullable=True,
        comment="Kazanılan puan"
    )

    # İlişkiler
    user = relationship("User", back_populates="tasks")
    task = relationship("Task", back_populates="user_tasks")
