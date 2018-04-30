import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    id: applicationWindow
    visible: true
    //visibility: ApplicationWindow.Maximized
    width: 840
    height: 720
    title: qsTr("Material Keyboard")
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    property int fwidth: 89
    property int fheight: 60
    property int sizeoffont: 15
    property bool on: true

    function toggle(){
        if (mySwitch.on == true){
            Material.theme = Material.Dark
        }
    }

    function numcheck(){
        if(button18.checked){
            num123.visible = true;
            num456.visible = true;
            num789.visible = true;
        }
        else{
            num123.visible = false;
            num456.visible = false;
            num789.visible = false;
        }
    }

    function symcheck(){
        if(button18.checked){
            num123.visible = false;
            num456.visible = false;
            num789.visible = false;
            button18.checked = false;
        }
        if(button16.checked){
            symbol123.visible = true;
            symbol456.visible = true;
            symbol789.visible = true;
            symbol101112.visible = true;
        }
        else{
            symbol123.visible = false;
            symbol456.visible = false;
            symbol789.visible = false;
            symbol101112.visible = false;
        }
    }

    function echo(str){
        if(caps.checked){
            str=str.charCodeAt(0);
            str-=32  //capital and small letter have same difference so this line converts to CAPS
            str=String.fromCharCode(str);
        }

        edittextArea.text+=str;
        collapseAll();
        var s=edittextArea.text.split(" ");
        var db = LocalStorage.openDatabaseSync("wordList","1.0","text predictor",10485760);
        pred1.text=""
        pred2.text=""
        pred3.text=""
        pred4.text="+"
        db.transaction(
                    function(tx){
                        var r=tx.executeSql("SELECT word FROM words WHERE  word LIKE '"+s[s.length-1]+"%' ORDER by usage DESC");
                        var r1="";
                        for(var i=0;i<r.rows.length;i++){
                            r1=+r.rows.item(i).word+"\t";
                            switch(i){
                            case 0: pred1.text=r.rows.item(i).word;
                                break;
                            case 1: pred2.text=r.rows.item(i).word;
                                break;
                            case 2: pred3.text=r.rows.item(i).word
                                break;
                            }
                        }
                        predictText.text = r1;
                        console.log(r1);
                    }
                    )
        console.log(s[s.length-1]);
    }
    function collapseAll(){
        abc_3.visible=false;
        def_3.visible=false;
        ghi_3.visible=false;
        jkl_4.visible=false;
        mno_4.visible=false;
        pqrs_4.visible=false;
        tuv_5.visible=false;
        wxyz_5.visible=false;
        row3.visible=true;
        row4.visible=true;
        row5.visible=true;
        console.log("Collapse")
    }
    function expand(keyset,row){
        var str=keyset.toString();
        //console.log(str);
        keyset.visible=true;
        if(row == 3)
            row3.visible=false
        else if(row == 4)
            row4.visible=false
        else
            row5.visible=false
    }

    function usePrediction(str){
        var txt=edittextArea.text;
        txt=txt.split(" ");
        txt[txt.length-1]=str;
        txt=txt.join(" ");
//        var db = LocalStorage.openDatabaseSync("wordList","1.0","text predictor",10485760);
//        db.transaction(
//                    function(tx){
//                        tx.executeSql("UPDATE words SET usage=usage+1 WHERE word='"+str+"';");
//                    })
        edittextArea.text=txt;
    }

    function addToDict(){
        var str=edittextArea.text.split(" ");
        str=str[str.length-1];
        console.log("legit learning?  "+(pred1.text!==str && pred2.text!==str && pred3.text!==str));
        if(pred1.text!==str && pred2.text!==str && pred3.text!==str){
            var db = LocalStorage.openDatabaseSync("wordList","1.0","text predictor",10485760);
            db.transaction(
                        function(tx){
                            tx.executeSql("INSERT INTO words VALUES(?,?)",[str,1]);
            });
        }
    }


    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            id: pagead

            Row {
                id: row
                x: 160
                y: 20
                width: 600
                //height: 200
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                TextArea {
                    id: edittextArea
                    width: 600
                    height: 160
                    wrapMode: Text.NoWrap
                    font.pointSize: 20
                    textFormat: Text.PlainText
                    placeholderText: qsTr("Click here to enter text")
                    Keys.onEscapePressed: undo()
                }

                Button {
                    id: button19
                    y: 45
                    width: 64
                    onClicked: edittextArea.clear()
                    text: qsTr("Clear")
                }
            }

            Row {
                id: row1
                width: 600
                height: 56
                padding: 0
                anchors.top: row.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: copy
                    width: 88
                    text: qsTr("Copy")
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    padding: 20
                    onClicked: edittextArea.copy()
                }

                Button {
                    id: cut
                    width: 88
                    text: qsTr("Cut")
                    anchors.left: copy.right
                    anchors.leftMargin: 10
                    padding: 20
                    onClicked: edittextArea.cut()
                }

                Button {
                    id: paste
                    width: 88
                    text: qsTr("paste")
                    anchors.left: cut.right
                    anchors.leftMargin: 10
                    padding: 20
                    onClicked: edittextArea.paste()
                }

                Button {
                    id: select
                    width: 88
                    text: qsTr("select")
                    anchors.left: paste.right
                    anchors.leftMargin: 10
                    padding: 20
                    onClicked: edittextArea.selectAll()
                }

                Button {
                    id: enter
                    width: 88
                    text: qsTr("enter")
                    anchors.left: select.right
                    anchors.leftMargin: 10
                    padding: 20
                    onClicked: edittextArea.append("\n")
                }

                Button {
                    id: del
                    width: 88
                    text: qsTr("delete")
                    anchors.left: enter.right
                    anchors.leftMargin: 10
                    padding: 20
                    onClicked: edittextArea.remove(edittextArea.length-1,edittextArea.length)
                }
            }

            Row {
                id: row2
                width: 600
                height: 56
                anchors.top: row1.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                TabButton {
                    id: pred1
                    width: 150
                    text: qsTr("an")
                    Material.foreground: Material.Blue
                    onClicked:usePrediction(this.text)
                }

                TabButton {
                    id: pred2
                    width: 150
                    text: qsTr("at")
                    Material.foreground: Material.Blue
                    onClicked:usePrediction(this.text)
                }

                TabButton {
                    id: pred3
                    width: 150
                    text: qsTr("are")
                    Material.foreground: Material.Blue
                    onClicked:usePrediction(this.text)
                }

                TabButton {
                    id: pred4
                    width: 150
                    text: qsTr("+")
                    Material.foreground: Material.Blue
                    onClicked:addToDict()
                }
            }

            Row {
                id: row3
                width: 600
                height: 66
                anchors.horizontalCenterOffset: 0
                anchors.top: row2.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: a_3
                    width: 160
                    text: qsTr("abc")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(abc_3,3)
                }

                Button {
                    id: d_3
                    width: 160
                    text: qsTr("def")
                    anchors.left: a_3.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(def_3,3)
                }

                Button {
                    id: g_3
                    width: 160
                    text: qsTr("ghi")
                    anchors.left: d_3.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(ghi_3,3)
                }
            }

            Row {
                id: abc_3
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: row2.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: button71
                    width: 160
                    text: qsTr("a")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("a")
                }

                Button {
                    id: button81
                    width: 160
                    text: qsTr("b")
                    anchors.left: button71.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("b")
                }

                Button {
                    id: button91
                    width: 160
                    text: qsTr("c")
                    anchors.left: button81.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("c")
                }
            }

            Row {
                id: def_3
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: row2.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: button72
                    width: 160
                    text: qsTr("d")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("d")
                }

                Button {
                    id: button82
                    width: 160
                    text: qsTr("e")
                    anchors.left: button72.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("e")
                }

                Button {
                    id: button92
                    width: 160
                    text: qsTr("f")
                    anchors.left: button82.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("f")
                }
            }

            Row {
                id: ghi_3
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: row2.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: button73
                    width: 160
                    text: qsTr("g")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("g")
                }

                Button {
                    id: button83
                    width: 160
                    text: qsTr("h")
                    anchors.left: button73.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("h")
                }

                Button {
                    id: button93
                    width: 160
                    text: qsTr("i")
                    anchors.left: button83.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("i")
                }
            }

            Row {
                id: row4
                width: 600
                height: 66
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: row3.bottom
                anchors.topMargin: 5


                Button {
                    id: j_4
                    width: 160
                    text: qsTr("jkl")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(jkl_4,4)
                }

                Button {
                    id: m_4
                    width: 160
                    text: qsTr("mno")
                    anchors.left: j_4.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(mno_4,4)
                }
                Button {
                    id: p_4
                    width: 160
                    text: qsTr("pqrs")
                    anchors.left: m_4.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(pqrs_4,4)
                }
            }

            Row {
                id: jkl_4
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: row3.bottom
                anchors.topMargin: 5


                Button {
                    id: button101
                    width: 160
                    text: qsTr("j")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("j")
                }

                Button {
                    id: button111
                    width: 160
                    text: qsTr("k")
                    anchors.left: button101.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("k")
                }
                Button {
                    id: button121
                    width: 160
                    text: qsTr("l")
                    anchors.left: button111.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("l")
                }
            }

            Row {
                id: mno_4
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: row3.bottom
                anchors.topMargin: 5


                Button {
                    id: button102
                    width: 160
                    text: qsTr("m")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("m")
                }

                Button {
                    id: button112
                    width: 160
                    text: qsTr("n")
                    anchors.left: button102.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("n")
                }
                Button {
                    id: button122
                    width: 160
                    text: qsTr("o")
                    anchors.left: button112.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("o")
                }
            }

            Row {
                id: pqrs_4
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: row3.bottom
                anchors.topMargin: 5


                Button {
                    id: button103
                    width: 160
                    text: qsTr("p")
                    anchors.left: parent.left
                    anchors.leftMargin: 90
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("p")
                }

                Button {
                    id: button113
                    width: 160
                    text: qsTr("q")
                    anchors.left: button103.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("q")
                }
                Button {
                    id: button123
                    width: 160
                    text: qsTr("r")
                    anchors.left: button113.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("r")
                }
                Button {
                    id: button123s
                    width: 160
                    text: qsTr("s")
                    anchors.left: button123.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("s")
                }
            }

            Row {
                id: row5
                width: 600
                height: 66
                anchors.top: row4.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter


                Button {
                    id: t_5
                    width: 160
                    text: qsTr("tuv")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(tuv_5,5)
                }
                Button {
                    id: w_5
                    width: 160
                    text: qsTr("wxyz")
                    anchors.left: t_5.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: expand(wxyz_5,5)
                }
                Button {
                    id: caps
                    width: 160
                    text: qsTr("caps")
                    checkable: true
                    anchors.left: w_5.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                }
            }

            Row {
                id: tuv_5
                width: 600
                height: 66
                visible: false
                anchors.top: row4.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter


                Button {
                    id: button55
                    width: 160
                    text: qsTr("t")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("t")
                }
                Button {
                    id: button145
                    width: 160
                    text: qsTr("u")
                    anchors.left: button55.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("u")
                }
                Button {
                    id: button155
                    width: 160
                    text: qsTr("v")
                    checkable: false
                    anchors.left: button145.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("v")
                }
            }

            Row {
                id: wxyz_5
                width: 600
                height: 66
                visible: false
                anchors.top: row4.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter


                Button {
                    id: button132
                    width: 160
                    text: qsTr("w")
                    anchors.left: parent.left
                    anchors.leftMargin: 90
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("w")
                }
                Button {
                    id: button142
                    width: 160
                    text: qsTr("x")
                    anchors.left: button132.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("x")
                }
                Button {
                    id: button152
                    width: 160
                    text: qsTr("y")
                    anchors.left: button142.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("y")
                }
                Button {
                    id: button162
                    width: 160
                    text: qsTr("z")
                    anchors.left: button152.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("z")
                }
            }


            Row {
                id: row6
                width: 600
                height: 66
                anchors.top: row5.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter


                Button {
                    id: button16
                    width: 160
                    text: qsTr("SYM")
                    checkable: true
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: symcheck()
                }

                Button {
                    id: button17
                    width: 160
                    text: qsTr("0")
                    anchors.left: button16.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: echo("0")
                }
                Button {
                    id: button18
                    width: 160
                    text: qsTr("NUM")
                    checkable: true
                    anchors.left: button17.right
                    anchors.leftMargin: 10
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: numcheck()
                }
            }

            Row {
                id: row7
                x: 160
                width: 600
                height: 66
                anchors.top: row6.bottom
                anchors.topMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: button
                    width: 500
                    text: qsTr("Space")
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    padding: 25
                    font.pointSize: sizeoffont
                    onClicked: edittextArea.insert(edittextArea.length ," ")
                }
            }

            Row {
                id: num123
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: row2.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: buttonnum1
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    text: qsTr("1")
                    onClicked: echo("1")
                }

                Button {
                    id: buttonnum2
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: buttonnum1.right
                    anchors.leftMargin: 10
                    text: qsTr("2")
                    onClicked: echo("2")
                }

                Button {
                    id: buttonnum3
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: buttonnum2.right
                    anchors.leftMargin: 10
                    text: qsTr("3")
                    onClicked: echo("3")
                }
            }

            Row {
                id: num456
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: num123.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: buttonnum4
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    text: qsTr("4")
                    onClicked: echo("4")
                }

                Button {
                    id: buttonnum5
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: buttonnum4.right
                    anchors.leftMargin: 10
                    text: qsTr("5")
                    onClicked: echo("5")
                }

                Button {
                    id: buttonnum6
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: buttonnum5.right
                    anchors.leftMargin: 10
                    text: qsTr("6")
                    onClicked: echo("6")
                }
            }

            Row {
                id: num789
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: num456.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: buttonnum7
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    text: qsTr("7")
                    onClicked: echo("7")
                }

                Button {
                    id: buttonnum8
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: buttonnum7.right
                    anchors.leftMargin: 10
                    text: qsTr("8")
                    onClicked: echo("8")
                }

                Button {
                    id: buttonnum9
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: buttonnum8.right
                    anchors.leftMargin: 10
                    text: qsTr("9")
                    onClicked: echo("9")
                }
            }

            Row {
                id: symbol123
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: row2.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: symbol1
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    text: qsTr("!")
                    onClicked: echo("!")
                }

                Button {
                    id: symbol2
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: symbol1.right
                    anchors.leftMargin: 10
                    text: qsTr("@")
                    onClicked: echo("@")
                }

                Button {
                    id: symbol3
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: symbol2.right
                    anchors.leftMargin: 10
                    text: qsTr("#")
                    onClicked: echo("#")
                }
            }

            Row {
                id: symbol456
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: symbol123.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: symbol4
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    text: qsTr("$")
                    onClicked: echo("$")
                }

                Button {
                    id: symbol5
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: symbol4.right
                    anchors.leftMargin: 10
                    text: qsTr("%")
                    onClicked: echo("%")
                }

                Button {
                    id: symbol6
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: symbol5.right
                    anchors.leftMargin: 10
                    text: qsTr("*")
                    onClicked: echo("*")
                }
            }

            Row {
                id: symbol789
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: num456.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: symbol7
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: parent.left
                    anchors.leftMargin: 55
                    text: qsTr("(")
                    onClicked: echo("(")
                }

                Button {
                    id: symbol8
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: symbol7.right
                    anchors.leftMargin: 10
                    text: qsTr(")")
                    onClicked: echo(")")
                }

                Button {
                    id: symbol9
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: symbol8.right
                    anchors.leftMargin: 10
                    text: qsTr("&")
                    onClicked: echo("&")
                }
            }

            Row {
                id: symbol101112
                width: 600
                height: 66
                visible: false
                anchors.horizontalCenterOffset: 0
                anchors.top: num789.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: symbol10
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: parent.left
                    anchors.leftMargin: 243
                    text: qsTr(".")
                    onClicked: echo(".")
                }

                Button {
                    id: symbol11
                    width: 160
                    padding: 25
                    font.pointSize: sizeoffont
                    anchors.left: symbol10.right
                    anchors.leftMargin: 10
                    text: qsTr(",")
                    onClicked: echo(",")
                }
            }

        }


        Page {
            Label {
                text: qsTr("Second page")
                anchors.centerIn: parent
            }
        }
    }

    footer: TabBar {
        id: tabBar
        visible: true
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("Keyboard")
        }
        TabButton {
            text: qsTr("Setup")
        }
    }

    /*Prediciton Logic*/

}
