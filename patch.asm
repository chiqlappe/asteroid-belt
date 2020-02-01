;=============================
;PC-8001 "ASTEROID BELT"用
;インベーダー音源パッチ
;2020/02/01
;=============================

;使い方
;(1)ゲームのBASICファイルと機械語ファイルをロードする
;(2)BASICの150行を CLEAR 300,&HCFFF に修正する
;(3)このパッチプログラムをロードする
;(4)モニタから GD000 を実行する
;(5)ベーシックから RUN を実行する
;
;・パッチを当てた機械語プログラムを保存するには、モニタから WD000,E6FF を実行して下さい
;・音が止まらない時は、OUT 16,255 を実行して下さい

;-----------------------------

FALSE	EQU	0

BOMBB	EQU	00000001B	;爆発音
MSSLB	EQU	00000010B	;ミサイル発射音
UFOHITB	EQU	00000100B	;UFOヒット音
THITB	EQU	00001000B	;ターゲットヒット音
STEPB	EQU	00010000B	;行進音
UFOB	EQU	00100000B	;UFO飛行音
PORT	EQU	10H		;サウンドボードのポート番号
CLK1	EQU	0D7B3H
MACLK	EQU	0E64AH
TIMR2	EQU	0D78EH
Z0202	EQU	0D6D3H
INIT1	EQU	0E3DAH


	ORG	0D000H

;-----------------------------
;パッチを当てる
;-----------------------------
PATCH:
	LD	HL,PATCH_DATA
.L1:	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,00H
	LD	A,E
	AND	A
	JP	Z,081H
	LDIR
	JR	.L1

;-----------------------------
;サウンドボードを初期化する
;-----------------------------
SNDINIT:
	LD	A,0FFH
	OUT	(PORT),A
	LD	(SND),A
	JP	INIT1

;-----------------------------
;ビームカー出現時のウェイト
;-----------------------------
CARWAIT:
	PUSH	BC
	LD	BC,4000H
.L1:	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,.L1
	POP	BC
	RET

;-----------------------------
;UFO飛行音を発生
;-----------------------------
UFOSND:
	LD	C,UFOB
	JR	PLAYSND

;-----------------------------
;UFO飛行音を停止
;-----------------------------
UFOSND_STOP:
	LD	C,UFOB
	JR	STOPSND

;-----------------------------
;UFOヒット音を発生
;-----------------------------
UHITSND:
	LD	C,UFOHITB
	JR	PLAYSND

;-----------------------------
;UFOヒット音を停止
;-----------------------------
UHITSND_STOP:
	LD	C,UFOHITB
	JR	STOPSND

;-----------------------------
;ミサイル発射音を発生
;-----------------------------
SHOTSND:
	LD	C,MSSLB
	JR	PLAYSND

;-----------------------------
;ヒット音を発生
;-----------------------------
HITSND:
	LD	C,THITB
	JR	PLAYSND

;-----------------------------
;爆発音を発生
;-----------------------------
BOMBSND:
	LD	C,BOMBB
	JR	PLAYSND

;-----------------------------
;爆発音を停止
;-----------------------------
BOMBSND_STOP:
	LD	C,BOMBB
	JR	STOPSND

;-----------------------------
;ステップ音を発生
;-----------------------------
STEPSND:
	LD	C,STEPB
	JR	PLAYSND

;-----------------------------
;ステップ音を停止
;-----------------------------
STEPSND_STOP:
	LD	C,STEPB
	JR	STOPSND

;-----------------------------
;ミス音を発生
;-----------------------------
MISSSND:
	CALL	STEPSND_STOP
	JP	BOMBSND

;-----------------------------
;ミス音を停止
;-----------------------------
MISSSND_STOP:
	JP	BOMBSND_STOP

;-----------------------------
;ステージクリア音を発生
;-----------------------------
CLEARSND:
	CALL	STEPSND_STOP
	JP	UHITSND

;-----------------------------
;次のステージへ
;-----------------------------
NEXTSTAGE:
	CALL	UHITSND_STOP
	LD	D,0FFH
	CALL	TIMR2
	JP	Z0202

;-----------------------------
;音を発生
;IN	C=ビットパターン
;-----------------------------
PLAYSND:
	LD	A,(SND)
	OR	C
	OUT	(PORT),A
	XOR	C
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;音を停止
;IN	C=ビットパターン
;-----------------------------
STOPSND:
	LD	A,(SND)
	OR	C
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;ステップ音を発生
;-----------------------------
BGM:
	CALL	CLK1

	LD	A,(MACLK)
	AND	00001111B
	JR	NZ,.L1

	LD	A,(SND)
	OR	A
	SBC	A,01000000B
	LD	(SND),A

	CALL	STEPSND
	JR	.EXIT

.L1:	AND	00000011B
	JR	NZ,.EXIT
	CALL	STEPSND_STOP

.EXIT:
	RET

;=============================

PATCH_DATA:

;BGM
	DW	0D6D9H
	DB	03H
	CALL	BGM

;サウンド初期化
	DW	0D6D0H
	DB	03H
	CALL	SNDINIT

;出現音
	DW	0D903H
	DB	06H
	CALL	UFOSND
	JP	CARWAIT

	DW	0D8FEH
	DB	03H
	CALL	UFOSND_STOP

;爆発音
	DW	0DF84H
	DB	03H
	CALL	MISSSND

	DW	0DF97H
	DB	03H
	NOP
	NOP
	NOP

	DW	0DFB0H
	DB	03H
	NOP
	NOP
	NOP

	DW	0DFC3H
	DB	03H
	NOP
	NOP
	NOP

	DW	0DFD6H
	DB	03H
	NOP
	NOP
	NOP

	DW	0DFE5H
	DB	03H
	CALL	MISSSND_STOP

;ビーム発射音
	DW	0DACCH
	DB	04H
	CALL	SHOTSND
	RET

;ALIEN ヒット音
	DW	0DC02H
	DB	06H
	NOP
	NOP
	NOP
	CALL	HITSND

;INVADER ヒット音
	DW	0DC11H
	DB	06H
	NOP
	NOP
	NOP
	CALL	HITSND

;UFO ヒット音
	DW	0DBD8H
	DB	06H
	NOP
	NOP
	NOP
	CALL	HITSND

;面クリア音
	DW	0DF05H
	DB	01H
	DB	0AH

	DW	0DF0FH
	DB	03H
	CALL	CLEARSND

	DW	0DF20H
	DB	03H
	NOP
	NOP
	NOP

	DW	0DF2AH
	DB	03H
	JP	NEXTSTAGE

;ミサイル発生率
;	DW	0DDC0H
;	DB	01H
;	DB	03H


;END OF DATA
	DB	00H,00H,00H


SND:	DB	00H		;ポート10Hに出力した値



