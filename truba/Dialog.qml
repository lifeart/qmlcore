Activity {
	id: dialogProto;
	signal accepted;
	signal canceled;
	property string okText:	"OK";
	property string cancelText: "Отмена";
	property string title: "";
	property int innerWidth: 500;
	property int innerHeight: 350;
	anchors.left: renderer.left;
	anchors.right: renderer.right;
	width: renderer.width;
	height: renderer.height;
	visible: active;
	z: parent.z + 1000;

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;
	}

	Rectangle {
		id: innerPanel;
		width: parent.innerWidth;
		height: parent.innerHeight;
		color: colorTheme.backgroundColor;
		radius: 1;
		anchors.centerIn: parent;
		effects.shadow.blur: 15;
		effects.shadow.spread: 1;
		effects.shadow.color: "#0005";

		Text {
			anchors.top: parent.top;
			anchors.topMargin: 10;
			width: parent.width;
			horizontalAlignment: Text.AlignHCenter;
			text: dialogProto.title;
			color: colorTheme.textColor;
			font.pointSize: 24;
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 10;
			spacing: 10;

			Button {
				text: dialogProto.okText;
				onClicked: { dialogProto.accepted(); }
			}

			Button {
				text: dialogProto.cancelText;
				onClicked: { dialogProto.canceled(); }
			}
		}
	}

	onCanceled: { this.stop(); }
}