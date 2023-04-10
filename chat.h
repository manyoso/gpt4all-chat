#ifndef CHAT_H
#define CHAT_H

#include <QObject>
#include <QUuid>
#include <QtQml>
#include <QQmlListProperty>

class ChatItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QString prompt READ prompt WRITE setPrompt NOTIFY promptChanged)
    Q_PROPERTY(bool currentResponse READ isCurrentResponse WRITE setCurrentResponse NOTIFY currentResponseChanged)
    QML_ELEMENT

public:
    explicit ChatItem(QObject *parent = nullptr) : QObject(parent) {}

    QString name() const { return m_name; }
    void setName(const QString &name)
    {
        if (name == m_name) return;
        m_name = name;
        emit nameChanged();
    }

    QString value() const { return m_value; }
    void setValue(const QString &value)
    {
        if (value == m_value) return;
        m_value = value;
        emit valueChanged();
    }

    QString prompt() const { return m_prompt; }
    void setPrompt(const QString &prompt)
    {
        if (prompt == m_prompt) return;
        m_prompt = prompt;
        emit promptChanged();
    }

    bool isCurrentResponse() const { return m_isCurrentResponse; }
    void setCurrentResponse(bool b)
    {
        if (b == m_isCurrentResponse) return;
        m_isCurrentResponse = b;
        emit currentResponseChanged();
    }

Q_SIGNALS:
    void nameChanged();
    void valueChanged();
    void promptChanged();
    void currentResponseChanged();

private:
    QString m_name;
    QString m_value;
    QString m_prompt;
    bool m_isCurrentResponse = false;
};

class Chat : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QQmlListProperty<ChatItem> chatModel READ chatModel NOTIFY chatModelChanged)
    QML_ELEMENT
//    QML_UNCREATABLE("Only creatable from c++!")

public:
    explicit Chat(QObject *parent = nullptr) : QObject(parent)
    {
        m_id = QUuid::createUuid();
        emit idChanged();
        m_name = "...";
        emit nameChanged();
    }

    QString id() const { return m_id.toString(QUuid::WithoutBraces); }
    QString name() const { return m_name; }
    QQmlListProperty<ChatItem> chatModel()
    {
        return QQmlListProperty<ChatItem>(this, &m_chatModel);
    }

    Q_INVOKABLE ChatItem* addItem()
    {
        m_chatModel.append(new ChatItem(this));
        emit chatModelChanged();
        return m_chatModel.last();
    }

    Q_INVOKABLE ChatItem *lastItem()
    {
        if (m_chatModel.isEmpty())
            return nullptr;
        return m_chatModel.last();
    }

Q_SIGNALS:
    void idChanged();
    void nameChanged();
    void chatModelChanged();

private:
    QUuid m_id;
    QString m_name;
    QList<ChatItem*> m_chatModel;
};

#endif // CHAT_H
