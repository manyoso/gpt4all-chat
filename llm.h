#ifndef LLM_H
#define LLM_H

#include <QObject>
#include <QThread>

#include "gptj.h"
#include "chat.h"

class GPTJObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isModelLoaded READ isModelLoaded NOTIFY isModelLoadedChanged)
    Q_PROPERTY(QString response READ response NOTIFY responseChanged)

public:
    GPTJObject();

    bool loadModel();
    bool isModelLoaded() const;
    void resetResponse();
    void stopGenerating() { m_stopGenerating = true; }

    QString response() const;

public Q_SLOTS:
    bool prompt(const QString &prompt);

Q_SIGNALS:
    void isModelLoadedChanged();
    void responseChanged();
    void responseStarted();
    void responseStopped();

private:
    bool handleResponse(const std::string &response);

private:
    GPTJ *m_gptj;
    std::string m_response;
    QThread m_llmThread;
    std::atomic<bool> m_stopGenerating;
};

class LLM : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isModelLoaded READ isModelLoaded NOTIFY isModelLoadedChanged)
    Q_PROPERTY(QString response READ response NOTIFY responseChanged)
    Q_PROPERTY(bool responseInProgress READ responseInProgress NOTIFY responseInProgressChanged)
    Q_PROPERTY(QList<Chat*> chatList READ chatList NOTIFY chatListChanged)
    Q_PROPERTY(Chat* currentChat READ currentChat WRITE setCurrentChat NOTIFY currentChatChanged)

public:
    static LLM *globalInstance();

    Q_INVOKABLE bool isModelLoaded() const;
    Q_INVOKABLE void prompt(const QString &prompt);
    Q_INVOKABLE void resetResponse();
    Q_INVOKABLE void stopGenerating();

    QString response() const;
    bool responseInProgress() const { return m_responseInProgress; }

    Q_INVOKABLE QString addChat();
    Q_INVOKABLE void removeChat(Chat *chat);
    Q_INVOKABLE void saveChat(Chat *chat);
    Q_INVOKABLE void copyChat(Chat *chat);

    QList<Chat*> chatList() const;
    Chat *currentChat() const;
    void setCurrentChat(Chat *chat);

Q_SIGNALS:
    void isModelLoadedChanged();
    void responseChanged();
    void responseInProgressChanged();
    void promptRequested(const QString &prompt);
    void resetResponseRequested();
    void chatListChanged();
    void currentChatChanged();

private Q_SLOTS:
    void responseStarted();
    void responseStopped();

private:
    GPTJObject *m_gptj;
    QList<Chat*> m_chatList;
    Chat *m_currentChat;
    bool m_responseInProgress;

private:
    explicit LLM();
    ~LLM() {}
    friend class MyLLM;
};

#endif // LLM_H
