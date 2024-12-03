import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.components 3.0 as PC3

Kirigami.ScrollablePage {
    readonly property alias cfg_percentTextCompRepCheck: percentTextCompRepCheck.checked
    readonly property alias cfg_boldCompRep: boldCompRep.checked
    readonly property alias cfg_italicCompRep: italicCompRep.checked
    readonly property alias cfg_fontSizeCompRep: fontSizeCompRep.value
    readonly property alias cfg_colorCompRep: colorCompRep.color
    readonly property alias cfg_diffColorCompRepCheck: diffColorCompRepCheck.checked
    readonly property alias cfg_diffColorCompRep: diffColorCompRep.color

    readonly property alias cfg_titleCheck: titleCheck.checked
    readonly property alias cfg_titleCheckText: titleCheckText.checked
    readonly property alias cfg_titleText: titleText.text
    readonly property alias cfg_boldFullRepTitle: boldFullRepTitle.checked
    readonly property alias cfg_italicFullRepTitle: italicFullRepTitle.checked
    readonly property alias cfg_fontSizeFullRepTitle: fontSizeFullRepTitle.value
    readonly property alias cfg_colorFullRepTitle: colorFullRepTitle.color

    readonly property alias cfg_percentageCircleCheck: percentageCircleCheck.checked
    readonly property alias cfg_colorFullRepCircleO: colorFullRepCircleO.color
    readonly property alias cfg_colorFullRepCircleU: colorFullRepCircleU.color
    readonly property alias cfg_circleWidth: circleWidth.value
    readonly property alias cfg_circleSize: circleSize.value

    readonly property alias cfg_percentTextFullRepCheck: percentTextFullRepCheck.checked
    readonly property alias cfg_diffColorCompFullCheck: diffColorCompFullCheck.checked
    readonly property alias cfg_diffColorCompFull: diffColorCompFull.color
    readonly property alias cfg_boldFullRepPC: boldFullRepPC.checked
    readonly property alias cfg_italicFullRepPC: italicFullRepPC.checked
    readonly property alias cfg_fontSizeFullRepPC: fontSizeFullRepPC.value
    readonly property alias cfg_colorFullRepPC: colorFullRepPC.color

    readonly property alias cfg_lastUpdateTextCheck: lastUpdateTextCheck.checked
    readonly property alias cfg_boldFullRepLU: boldFullRepLU.checked
    readonly property alias cfg_italicFullRepLU: italicFullRepLU.checked
    readonly property alias cfg_fontSizeFullRepLU: fontSizeFullRepLU.value
    readonly property alias cfg_colorFullRepLU: colorFullRepLU.color

    Kirigami.FormLayout {
        anchors.fill: parent

        // Section: Control Panel View
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Control Panel View")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
        }
        
        // Allow to show a percent text
        PC3.CheckBox {
            id: percentTextCompRepCheck
            Kirigami.FormData.label: i18n("Show percent text:")
        }

        // Layout for formatting percent text
        RowLayout {
            visible: percentTextCompRepCheck.checked
            Kirigami.FormData.label: i18n("Percent text formatting:")

            PC3.SpinBox {
                id: fontSizeCompRep
                from: 8
                to: 48
            }

            // Bold toggle button
            PC3.ToolButton {
                id: boldCompRep

                checkable: true
                icon.name: "format-text-bold"
                display: AbstractButton.IconOnly
                text: i18n("Bold")
                height: Kirigami.Units.smallSpacing

                PC3.ToolTip {
                    text: i18n("<b>Bold</b>")
                }
            }

            // Italic toggle button
            PC3.ToolButton {
                id: italicCompRep

                checkable: true
                display: AbstractButton.IconOnly
                text: i18n("Italic")
                icon.name: "format-text-italic"
                height: Kirigami.Units.smallSpacing

                PC3.ToolTip {
                    text: i18n("<i>Italic</i>")
                }
            }

            // Color selection
            Rectangle {
                id: colorCompRep
                width: 20
                height: 20
            }

            PC3.ToolButton {
                text: i18n("Pick color")
                icon.name: "color-picker"
                onClicked: colorDialog.open()
            }

            // Color picker dialog
            ColorDialog {
                id: colorDialog
                selectedColor: colorCompRep.color
                title: i18n("Select a color")
                onAccepted: {
                    colorCompRep.color = selectedColor;
                }
            }
        }
        
        // Allow different text color under 20%
        PC3.CheckBox {
            id: diffColorCompRepCheck
            Kirigami.FormData.label: i18n("Enable different text color under 20%:")
        }

        // Layout for configuring a different color for percentages under 20%
        RowLayout { 
            visible: diffColorCompRepCheck.checked    
            Kirigami.FormData.label: i18n("Percent text color under 20%:")

            RowLayout {
                // Color selection
                Rectangle {
                    id: diffColorCompRep
                    width: 20
                    height: 20
                }

                PC3.ToolButton {
                    text: i18n("Pick color")
                    icon.name: "color-picker"
                    onClicked: colorDialogDiff.open()
                }

                // Color picker dialog
                ColorDialog {
                    id: colorDialogDiff
                    selectedColor: diffColorCompRep.color
                    title: i18n("Select a color")
                    onAccepted: {
                        diffColorCompRep.color = selectedColor;
                    }
                }
            }
        }

        // Section: Full Widget View
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Full Widget View")
        }
        
        // Allow to show a model title
        PC3.CheckBox {
            id: titleCheck
            Kirigami.FormData.label: i18n("Show model title text:")
        }

        // Allows enabling a custom title
        PC3.CheckBox {
            id: titleCheckText
            visible: titleCheck.checked
            Kirigami.FormData.label: i18n("Enable custom title text:")
        } 
        
        // Custom title input field
        TextField {
            id: titleText
            visible: titleCheck.checked
            enabled: titleCheckText.checked
            placeholderText: i18n("Enter the title text")
            Kirigami.FormData.label: i18n("Custom title text:")
        }

        // Formatting options for the title
        RowLayout { 
            visible: titleCheck.checked    
            Kirigami.FormData.label: i18n("Title text formatting:")

            RowLayout {
                PC3.SpinBox {
                    id: fontSizeFullRepTitle
                    from: 8
                    to: 48
                }

                // Bold toggle button
                PC3.ToolButton {
                    id: boldFullRepTitle
                    checkable: true
                    icon.name: "format-text-bold"
                    display: AbstractButton.IconOnly
                    text: i18n("Bold")
                    height: Kirigami.Units.smallSpacing
                    PC3.ToolTip {
                        text: i18n("<b>Bold</b>")
                    }
                }

                // Italic toggle button
                PC3.ToolButton {
                    id: italicFullRepTitle
                    checkable: true
                    display: AbstractButton.IconOnly
                    text: i18n("Italic")
                    icon.name: "format-text-italic"
                    height: Kirigami.Units.smallSpacing
                    PC3.ToolTip {
                        text: i18n("<i>Italic</i>")
                    }
                }

                // Color selection
                Rectangle {
                    id: colorFullRepTitle
                    width: 20
                    height: 20
                }

                PC3.ToolButton {
                    text: i18n("Pick color")
                    icon.name: "color-picker"
                    onClicked: colorDialog1.open()
                }

                // Color picker dialog
                ColorDialog {
                    id: colorDialog1
                    selectedColor: colorFullRepTitle.color
                    title: i18n("Select a color")
                    onAccepted: {
                        colorFullRepTitle.color = selectedColor;
                    }
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
        }

        // Allow to show a percentage circle
        PC3.CheckBox {
            id: percentageCircleCheck
            Kirigami.FormData.label: i18n("Show percentage circle:")
        }

        // Layout for configuring a progress circle width
        RowLayout {
            visible: percentageCircleCheck.checked
            Kirigami.FormData.label: i18n("Progress circle width:")
            PC3.SpinBox {
                id: circleWidth
                from: 0
                to: 200
            }
        }

        // Layout for configuring a progress circle size
        RowLayout {
            visible: percentageCircleCheck.checked
            Kirigami.FormData.label: i18n("Progress circle size:")
            PC3.SpinBox {
                id: circleSize
                from: 20
                to: 200
            }
        }

        // Layout for configuring a different color for percentages over 20%
        RowLayout {
            visible: percentageCircleCheck.checked
            Kirigami.FormData.label: i18n("Circle color over 20%:")
            // Color selection
            Rectangle {
                id: colorFullRepCircleO
                width: 20
                height: 20
            }

            PC3.ToolButton {
                text: i18n("Pick color")
                icon.name: "color-picker"
                onClicked: colorDialogCircleO.open()
            }

            // Color picker dialog
            ColorDialog {
                id: colorDialogCircleO
                selectedColor: colorFullRepCircleO.color
                title: i18n("Select a color")
                onAccepted: {
                    colorFullRepCircleO.color = selectedColor;
                }
            }
        }

        // Layout for configuring a different color for percentages under 20%
        RowLayout {
            visible: percentageCircleCheck.checked
            Kirigami.FormData.label: i18n("Circle color under 20%:")
            // Color selection
            Rectangle {
                id: colorFullRepCircleU
                width: 20
                height: 20
            }

            PC3.ToolButton {
                text: i18n("Pick color")
                icon.name: "color-picker"
                onClicked: colorDialogCircleU.open()
            }

            // Color picker dialog
            ColorDialog {
                id: colorDialogCircleU
                selectedColor: colorFullRepCircleU.color
                title: i18n("Select a color")
                onAccepted: {
                    colorFullRepCircleU.color = selectedColor;
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
        }

        // Allow to show a percent text
        PC3.CheckBox {
            id: percentTextFullRepCheck
            Kirigami.FormData.label: i18n("Show percent text:")
        }
        
        // Formatting options for the percent title
        RowLayout {
            visible: percentTextFullRepCheck.checked
            Kirigami.FormData.label: i18n("Percent text formatting:")

            RowLayout {
                PC3.SpinBox {
                    id: fontSizeFullRepPC
                    from: 8
                    to: 48
                }

                // Bold toggle button
                PC3.ToolButton {
                    id: boldFullRepPC
                    checkable: true
                    icon.name: "format-text-bold"
                    display: AbstractButton.IconOnly
                    text: i18n("Bold")
                    height: Kirigami.Units.smallSpacing

                    PC3.ToolTip {
                        text: i18n("<b>Bold</b>")
                    }
                }

                // Italic toggle button
                PC3.ToolButton {
                    id: italicFullRepPC
                    checkable: true
                    display: AbstractButton.IconOnly
                    text: i18n("Italic")
                    icon.name: "format-text-italic"
                    height: Kirigami.Units.smallSpacing
                    PC3.ToolTip {
                        text: i18n("<i>Italic</i>")
                    }
                }

                // Color selection
                Rectangle {
                    id: colorFullRepPC
                    width: 20
                    height: 20
                }

                PC3.ToolButton {
                    text: i18n("Pick color")
                    icon.name: "color-picker"
                    onClicked: colorDialog2.open()
                }
                
                // Color picker dialog
                ColorDialog {
                    id: colorDialog2
                    selectedColor: colorFullRepPC.color
                    title: i18n("Select a color")
                    onAccepted: {
                        colorFullRepPC.color = selectedColor;
                    }
                }
            }
        }

        // Allow different text color under 20%
        PC3.CheckBox {
            id: diffColorCompFullCheck
            Kirigami.FormData.label: i18n("Enable different text color under 20%:")
        }

        // Formatting options for a different color for percentages under 20%
        RowLayout { 
            visible: diffColorCompFullCheck.checked    
            Kirigami.FormData.label: i18n("Percent text color under 20%:")

            RowLayout {
                // Color selection
                Rectangle {
                    id: diffColorCompFull
                    width: 20
                    height: 20
                }

                PC3.ToolButton {
                    text: i18n("Pick color")
                    icon.name: "color-picker"
                    onClicked: colorDialogDiffFull.open()
                }

                // Color picker dialog
                ColorDialog {
                    id: colorDialogDiffFull
                    selectedColor: diffColorCompFull.color
                    title: i18n("Select a color")
                    onAccepted: {
                        diffColorCompFull.color = selectedColor;
                    }
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: false
        }

        // Allow show last updated text
        PC3.CheckBox {
            id: lastUpdateTextCheck
            Kirigami.FormData.label: i18n("Show last updated text:")
        }

        // Formatting options for the last updated
        RowLayout {
            visible: lastUpdateTextCheck.checked
            Kirigami.FormData.label: i18n("Last updated text formatting:")

            RowLayout {
                PC3.SpinBox {
                    id: fontSizeFullRepLU
                    from: 8
                    to: 48
                }

                // Bold toggle button
                PC3.ToolButton {
                    id: boldFullRepLU
                    checkable: true
                    icon.name: "format-text-bold"
                    display: AbstractButton.IconOnly
                    text: i18n("Bold")
                    height: Kirigami.Units.smallSpacing
                    PC3.ToolTip {
                        text: i18n("<b>Bold</b>")
                    }
                }

                // Italic toggle button
                PC3.ToolButton {
                    id: italicFullRepLU
                    checkable: true
                    display: AbstractButton.IconOnly
                    text: i18n("Italic")
                    icon.name: "format-text-italic"
                    height: Kirigami.Units.smallSpacing
                    PC3.ToolTip {
                        text: i18n("<i>Italic</i>")
                    }
                }

                // Color selection
                Rectangle {
                    id: colorFullRepLU
                    width: 20
                    height: 20
                }

                PC3.ToolButton {
                    text: i18n("Pick color")
                    icon.name: "color-picker"
                    onClicked: colorDialog3.open()
                }

                // Color picker dialog
                ColorDialog {
                    id: colorDialog3
                    selectedColor: colorFullRepLU.color 
                    title: i18n("Select a color")
                    onAccepted: {
                        colorFullRepLU.color = selectedColor;
                    }
                }
            }
        }
    }
}
