-- 햇살 맥 설치 (인터넷에서 최신 버전 받기)
-- 창 위쪽의 ▶ (실행) 버튼을 누르면 설치가 시작돼요. (터미널 필요 없음)
-- GitHub(bjpaku-pixel/haetsal-releases) main/latest.json 의 맥용 조각을 받아 이어 붙이고 원본과 같은지 확인한 뒤
-- 응용 프로그램 폴더에 넣고 열어요. 처음 설치할 때, 또는 햇살을 다시 깔고 싶을 때 써요.

property base : "https://raw.githubusercontent.com/bjpaku-pixel/haetsal-releases/main"

display dialog ("햇살 최신 버전을 인터넷에서 받아 응용 프로그램 폴더에 설치할까요?" & return & "130MB쯤 받아요. 열려 있는 햇살은 잠깐 닫혔다가 다시 열려요.") buttons {"취소", "설치"} default button "설치" cancel button "취소" with title "햇살 설치"

set progress description to "햇살 최신 버전을 받는 중이에요… (1~2분)"

set sh to "set -e; T=$(mktemp -d /tmp/haetsal.XXXXXX); B=" & base & "; curl -fsSL --retry 2 -o $T/latest.json \"$B/latest.json?t=$(date +%s)\"; H=$(plutil -extract darwin.sha256 raw -o - $T/latest.json); : > $T/h.zip; i=0; while P=$(plutil -extract darwin.parts.$i.path raw -o - $T/latest.json 2>/dev/null); do case \"$P\" in files/*) ;; *) rm -rf $T; echo BADURL; exit 0;; esac; case \"$P\" in *..*) rm -rf $T; echo BADURL; exit 0;; esac; curl -fsSL --retry 2 \"$B/$P\" >> $T/h.zip; i=$((i+1)); done; if [ $i -eq 0 ]; then rm -rf $T; echo BADURL; exit 0; fi; S=$(shasum -a 256 $T/h.zip | cut -c1-64); if [ \"$S\" != \"$H\" ]; then rm -rf $T; echo BADSUM; exit 0; fi; mkdir $T/x; ditto -x -k $T/h.zip $T/x; A=$(ls $T/x | head -n 1); pkill -x ${A%.app} 2>/dev/null || true; i=0; while pgrep -x ${A%.app} >/dev/null && [ $i -lt 20 ]; do sleep 0.5; i=$((i+1)); done; rm -rf /Applications/$A '/Applications/햇살.app' 2>/dev/null || true; ditto $T/x/$A /Applications/$A; xattr -cr /Applications/$A; rm -rf $T; echo /Applications/$A"

try
	set appPath to do shell script sh
on error errText
	if errText contains "curl" or errText contains "resolve" or errText contains "connect" then
		display dialog ("인터넷에서 받지 못했어요. 인터넷 연결을 확인하고 다시 실행해 주세요." & return & return & errText) buttons {"확인"} default button 1 with title "햇살 설치" with icon caution
		return
	end if
	try
		set appPath to do shell script sh with administrator privileges
	on error errText2
		display dialog ("설치하지 못했어요." & return & return & errText2) buttons {"확인"} default button 1 with title "햇살 설치" with icon stop
		return
	end try
end try

if appPath is "BADSUM" or appPath is "BADURL" then
	display dialog "받은 파일이 원본과 달라요. 잠시 뒤 다시 실행해 주세요." buttons {"확인"} default button 1 with title "햇살 설치" with icon caution
	return
end if

-- 예전에 넣었던 '햇살.app'(0.8.0, 열리지 않던 것)이 남아 있으면 휴지통으로
if (do shell script "test -e '/Applications/햇살.app' && echo yes || echo no") is "yes" then
	try
		tell application "Finder" to delete (POSIX file "/Applications/햇살.app" as alias)
	end try
end if

do shell script "open " & quoted form of appPath
display dialog ("햇살을 설치했어요." & return & "앞으로는 햇살 왼쪽 위 업데이트 버튼으로 새 버전을 받으면 돼요." & return & return & "이 설치 파일은 지워도 돼요.") buttons {"확인"} default button 1 with title "햇살 설치"
