import QtQuick
import QtQuick.Controls
import llm
import gpt4all

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("GPT4All Chat")

    Rectangle {
        id: conversationList
        width: 300
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#202123"

        Button {
            id: newChat
            text: qsTr("New chat")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
            padding: 15
            background: Rectangle {
                opacity: .5
                border.color: "#7d7d8e"
                border.width: 1
                radius: 10
                color: "#343541"
            }
            onClicked: LLM.addChat()
        }

        ListView {
            id: chatListView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: newChat.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 15

            model: LLM.chatList

            delegate: Button {
                padding: 15
                width: chatListView.width

                contentItem: Text {
                    color: "#bababe"
                    text: modelData.name
                    elide: Text.ElideRight
                    clip: true
                }
            }
        }
    }

    property list<ChatItem> chatModel: LLM.currentChat.chatModel

    Rectangle {
        id: conversation
        color: "#343541"
        anchors.left: conversationList.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        ScrollView {
            id: scrollView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: textInput.top
            anchors.bottomMargin: 30
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            Rectangle {
                anchors.fill: parent
                color: "#444654"

                ListView {
                    id: listView
                    anchors.fill: parent
                    header: TextField {
                        id: modelName
                        width: parent.width
                        color: "#d1d5db"
                        padding: 20
                        font.pixelSize: 24
                        text: "Model: GPT4ALL-J-6B-4bit"
                        background: Rectangle {
                            color: "#444654"
                        }
                        focus: false
                        horizontalAlignment: TextInput.AlignHCenter
                    }

                    model: chatModel
                    delegate: TextArea {
                        text: modelData.currentResponse ? LLM.response : value
                        width: listView.width
                        color: "#d1d5db"
                        wrapMode: Text.WordWrap
                        focus: false
                        padding: 20
                        font.pixelSize: 24
                        cursorVisible: modelData.currentResponse ? LLM.responseInProgress : false
                        cursorPosition: text.length
                        background: Rectangle {
                            color: modelData.name === qsTr("Response: ") ? "#444654" : "#343541"
                        }

                        leftPadding: 100

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 20
                            anchors.topMargin: 20
                            width: 30
                            height: 30
                            radius: 5
                            color: modelData.name === qsTr("Response: ") ? "#10a37f" : "#ec86bf"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name === qsTr("Response: ") ? "R" : "P"
                                color: "white"
                            }
                        }
                    }

                    property bool shouldAutoScroll: true
                    property bool isAutoScrolling: false

                    Connections {
                        target: LLM
                        function onResponseChanged() {
                            if (listView.shouldAutoScroll) {
                                listView.isAutoScrolling = true
                                listView.positionViewAtEnd()
                                listView.isAutoScrolling = false
                            }
                        }
                    }

                    onContentYChanged: {
                        if (!isAutoScrolling)
                            shouldAutoScroll = atYEnd
                    }

                    Component.onCompleted: {
                        shouldAutoScroll = true
                        positionViewAtEnd()
                    }

                    footer: Item {
                        id: bottomPadding
                        width: parent.width
                        height: 60
                    }
                }
            }
        }

        Button {
            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15
                source: LLM.responseInProgress ? "qrc:/gpt4all/icons/stop_generating.svg" : "qrc:/gpt4all/icons/regenerate.svg"
            }
            leftPadding: 50
            text: LLM.responseInProgress ? qsTr("Stop generating") : qsTr("Regenerate response")
            onClicked: {
                if (LLM.responseInProgress)
                    LLM.stopGenerating()
                else {
                    LLM.resetResponse()
                    if (chatModel.count) {
                        var listElement = chatModel.get(chatModel.count - 1)
                        if (listElement.name === qsTr("Response: ")) {
                            listElement.currentResponse = true
                            listElement.value = LLM.response
                            LLM.prompt(listElement.prompt)
                        }
                    }
                }
            }
            anchors.bottom: textInput.top
            anchors.horizontalCenter: textInput.horizontalCenter
            anchors.bottomMargin: 40
            padding: 15
            background: Rectangle {
                opacity: .5
                border.color: "#7d7d8e"
                border.width: 1
                radius: 10
                color: "#343541"
            }
        }

        TextField {
            id: textInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 30
            color: "#dadadc"
            padding: 20
            font.pixelSize: 24
            placeholderText: qsTr("Send a message...")
            placeholderTextColor: "#7d7d8e"
            background: Rectangle {
                color: "#40414f"
                radius: 10
            }
            onAccepted: {
                LLM.stopGenerating()

                var item = LLM.currentChat.lastItem();
                if (item) {
                    item.currentResponse = false
                    item.value = LLM.response
                }

                var prompt = textInput.text + "\n"
                var item = LLM.currentChat.addItem();
                item.name = qsTr("Prompt: ")
                item.currentResponse = false
                item.value = textInput.text

                var item = LLM.currentChat.addItem();
                item.name = qsTr("Response: ")
                item.currentResponse = true
                item.prompt = prompt

                LLM.resetResponse()
                LLM.prompt(prompt)
                textInput.text = ""
            }

            Button {
                anchors.right: textInput.right
                anchors.verticalCenter: textInput.verticalCenter
                anchors.rightMargin: 15
                width: 30
                height: 30

                background: Image {
                    anchors.centerIn: parent
                    source: "qrc:/gpt4all/icons/send_message.svg"
                }

                onClicked: {
                    textInput.onAccepted()
                }
            }
        }
    }
}
