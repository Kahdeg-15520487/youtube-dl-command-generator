#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiTreeView.au3>
#include <GuiButton.au3>
#include <GuiComboBox.au3>
#include <ComboConstants.au3>
#include <String.au3>
#include <Array.au3>


Global Const $MAIN = " youtube-dl "
Global Const $EXTRACT_AUDIO = " --extract-audio "
Global Const $AUDIO_FORMAT = " --audio-format "
Global Const $OUTPUT = " --output "
Global Const $OUTPUT_TEMPLATE = "%(title)s.%(ext)s"
Global Const $YES_PLAYLIST = " --yes-playlist "
Global Const $NO_PLAYLIST = " --no-playlist "
Global Const $PLAYLIST_START = " --playlist-start "
Global Const $PLAYLIST_END = " --playlist-end "
Global Const $WRITE_SUB = " --write-sub "
Global Const $WRITE_AUTO_SUB = " --write-auto-sub "
Global Const $SUB_FORMAT = " --sub-format "
Global Const $SUB_LANG = " --sub-lang "
Global Const $SKIP_VIDEO =" --skip-download "

#Region ### START Koda GUI section ### Form=g:\workspace\autoit\youtube-dl-command-generator\mainform.kxf
$Form1_1_1 = GUICreate("Main", 615, 213, 192, 124)
$input_url = GUICtrlCreateInput("", 8, 8, 497, 21)
$chkbox_isSingle = GUICtrlCreateCheckbox("Download only this video", 8, 80, 145, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$chkbox_isMP3 = GUICtrlCreateCheckbox("Download as MP3", 8, 104, 145, 17)
$chkbox_exec = GUICtrlCreateCheckbox("Execute generated bat", 8, 128, 137, 17)
$chkbox_sub = GUICtrlCreateCheckbox("Download subtittle", 8, 152, 145, 17)
$Checkbox5 = GUICtrlCreateCheckbox("Checkbox5", 8, 176, 97, 17)
$btn_generate = GUICtrlCreateButton("Generate", 432, 80, 169, 121)
$input_dir = GUICtrlCreateInput("", 8, 40, 497, 21)
$btn_dir = GUICtrlCreateButton("Choose Folder", 520, 40, 83, 25)
$input_start = GUICtrlCreateInput("", 160, 80, 41, 21)
GUICtrlSetState(-1, $GUI_HIDE)
$input_end = GUICtrlCreateInput("", 224, 80, 41, 21)
GUICtrlSetState(-1, $GUI_HIDE)
$Label1 = GUICtrlCreateLabel("-->", 208, 83, 16, 17)
GUICtrlSetState(-1, $GUI_HIDE)
$combo_sublist = GUICtrlCreateCombo("Auto sub", 160, 152, 145, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetState(-1, $GUI_HIDE)
$chkbox_onlysub = GUICtrlCreateCheckbox("Only down sub", 312, 152, 97, 17)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $isSingle = False
Global $url
Global $dir
Global $sublang

While 1
	$url = GUICtrlRead($input_url)
	$sublang = GUICtrlRead($combo_sublist)

	;check if the input url is a playlist url
	If Not(StringInStr($url,"list")) And GUICtrlRead($chkbox_isSingle) == $GUI_UNCHECKED Then
		GUICtrlSetState($chkbox_isSingle,$GUI_CHECKED)
	EndIf

	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $btn_dir
			Local $path = FileSelectFolder("lala",@ScriptDir)
			GUICtrlSetData($input_dir,$path)

		Case $btn_generate
			Generate()

		Case $chkbox_isSingle
			If BitAND(GUICtrlRead($chkbox_isSingle), $BN_CLICKED) = $BN_CLICKED Then
                If _GUICtrlButton_GetCheck($chkbox_isSingle) Then
					GUICtrlSetData($chkbox_isSingle,"Download only this video")
					GUICtrlSetState($input_start,$GUI_HIDE)
					GUICtrlSetState($input_end,$GUI_HIDE)
					GUICtrlSetState($Label1,$GUI_HIDE)
                Else
					GUICtrlSetData($chkbox_isSingle,"Download the playlist")
					GUICtrlSetState($input_start,$GUI_SHOW)
					GUICtrlSetState($input_end,$GUI_SHOW)
					GUICtrlSetState($Label1,$GUI_SHOW)
                EndIf
			EndIf

		Case $chkbox_sub
			If BitAND(GUICtrlRead($chkbox_sub), $BN_CLICKED) = $BN_CLICKED Then
                If _GUICtrlButton_GetCheck($chkbox_sub) Then
					If (StringLen($url)>0) Then
						_GUICtrlComboBox_InsertString($combo_sublist,GetSubLang(),0)
						;MsgBox(0,"",GUICtrlRead($combo_sublist))
					EndIf
					GUICtrlSetState($combo_sublist,$GUI_SHOW)
					GUICtrlSetState($chkbox_onlysub,$GUI_SHOW)
                Else
                    ConsoleWrite("Checkbox unchecked... " & @CRLF)
					_GUICtrlComboBox_ResetContent($combo_sublist)
					_GUICtrlComboBox_AddString($combo_sublist,"Auto sub")
					GUICtrlSetState($combo_sublist,$GUI_HIDE)
					GUICtrlSetState($chkbox_onlysub,$GUI_HIDE)
                EndIf
			EndIf
	EndSwitch
WEnd

Func Generate()
	Local $command = $MAIN

	Local $isSingle = GUICtrlRead($chkbox_isSingle) == $GUI_CHECKED
	Local $start = Number(GUICtrlRead($input_start))
	Local $end = Number(GUICtrlRead($input_end))

	Local $isMP3 = GUICtrlRead($chkbox_isMP3) == $GUI_CHECKED

	Local $isSub = GUICtrlRead($chkbox_sub) == $GUI_CHECKED
	Local $isOnlySub = GUICtrlRead($chkbox_onlysub) == $GUI_CHECKED

	Local $dir = GUICtrlRead($input_dir)

	Local $isExec = GUICtrlRead($chkbox_exec) == $GUI_CHECKED

	If $isMP3 Then
		$command &= $EXTRACT_AUDIO & $AUDIO_FORMAT &"mp3"
	EndIf

	If $isSub Then
		If $sublang <> "Auto sub" Then
			$command &= $WRITE_SUB & $SUB_LANG & $sublang
		Else
			$command &= $WRITE_AUTO_SUB
		EndIf

		If $isOnlySub Then
			$command &= $SKIP_VIDEO
		EndIf
	EndIf

	If $isSingle Then
		$command &= $NO_PLAYLIST
	Else
		$command &= $YES_PLAYLIST
		If $start <> 0 Then $command &= $PLAYLIST_START & $start
		If $end <> 0 Then $command &= $PLAYLIST_END & $end
	EndIf

	If $dir <> "" Then
		$command &= $OUTPUT & '"' & $dir &'\' & $OUTPUT_TEMPLATE & '" '
	EndIf

	$command &= ' "' & GUICtrlRead($input_url) & '"'

	Local $file = FileOpen("generated.bat",$FO_OVERWRITE  + $FO_CREATEPATH)
	FileWrite($file,$command)
	FileClose($file)

	If $isExec Then
		Run(@ComSpec & " /C " & $command)
	EndIf
EndFunc

Func GetSubLang()
	Local $a_sublist
	Local $command = $MAIN & " --list-subs " & $url
	Local $cmdline = Run(@ComSpec & " /C " & $command,"", @SW_HIDE,$STDERR_CHILD + $STDOUT_CHILD)
	ProcessWaitClose($cmdline)
	Local $return = StdoutRead($cmdline)
	$a_sublist = StringSplit($return,@LF)
	Return StringLeft($a_sublist[UBound($a_sublist)-2],2)
EndFunc
