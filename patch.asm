;=============================
;PC-8001 "ASTEROID BELT"�p
;�C���x�[�_�[�����p�b�`
;2020/02/02
;=============================

;�g����
;(1)�Q�[����BASIC�t�@�C���Ƌ@�B��t�@�C�������[�h����
;(2)BASIC��150�s�� CLEAR 300,&HCFFF �ɏC������
;(3)���̃p�b�`�v���O���������[�h����
;(4)���j�^���� GD000 �����s����
;(5)�x�[�V�b�N���� RUN �����s����
;
;�E�p�b�`�𓖂Ă��@�B��v���O������ۑ�����ɂ́A���j�^���� WD000,E6FF �����s���ĉ�����
;�E�����~�܂�Ȃ����́AOUT 16,255 �����s���ĉ�����

;-----------------------------

FALSE	EQU	0

BOMBB	EQU	00000001B	;������
MSSLB	EQU	00000010B	;�~�T�C�����ˉ�
UFOHITB	EQU	00000100B	;UFO�q�b�g��
THITB	EQU	00001000B	;�^�[�Q�b�g�q�b�g��
STEPB	EQU	00010000B	;�s�i��
UFOB	EQU	00100000B	;UFO��s��
PORT	EQU	10H		;�T�E���h�{�[�h�̃|�[�g�ԍ�
CLK1	EQU	0D7B3H
MACLK	EQU	0E64AH
TIMR2	EQU	0D78EH
Z0202	EQU	0D6D3H
INIT1	EQU	0E3DAH
UFOCT	EQU	0E6AEH		;UFO�̑���

	ORG	0D000H

;-----------------------------
;�p�b�`�𓖂Ă�
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
;�T�E���h�{�[�h������������
;-----------------------------
SNDINIT:
	LD	A,0FFH
	OUT	(PORT),A
	LD	(SND),A
	JP	INIT1

;-----------------------------
;�r�[���J�[�o�����̃E�F�C�g
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
;UFO��s���𔭐�
;-----------------------------
UFOSND:
	LD	C,UFOB
	JR	PLAYSND

;-----------------------------
;UFO��s�����~
;-----------------------------
UFOSND_STOP:
	LD	C,UFOB
	JR	STOPSND

;-----------------------------
;UFO�q�b�g���𔭐�
;-----------------------------
UHITSND:
	LD	C,UFOHITB
	JR	PLAYSND

;-----------------------------
;UFO�q�b�g�����~
;-----------------------------
UHITSND_STOP:
	LD	C,UFOHITB
	JR	STOPSND

;-----------------------------
;�~�T�C�����ˉ��𔭐�
;-----------------------------
SHOTSND:
	LD	C,MSSLB
	JR	PLAYSND

;-----------------------------
;�q�b�g���𔭐�
;-----------------------------
HITSND:
	LD	C,THITB
	JR	PLAYSND

;-----------------------------
;�������𔭐�
;-----------------------------
BOMBSND:
	LD	C,BOMBB
	JR	PLAYSND

;-----------------------------
;���������~
;-----------------------------
BOMBSND_STOP:
	LD	C,BOMBB
	JR	STOPSND

;-----------------------------
;�X�e�b�v���𔭐�
;-----------------------------
STEPSND:
	LD	C,STEPB
	JR	PLAYSND

;-----------------------------
;�X�e�b�v�����~
;-----------------------------
STEPSND_STOP:
	LD	C,STEPB
	JR	STOPSND

;-----------------------------
;�~�X���𔭐�
;-----------------------------
MISSSND:
	CALL	STEPSND_STOP
	JP	BOMBSND

;-----------------------------
;�~�X�����~
;-----------------------------
MISSSND_STOP:
	JP	BOMBSND_STOP

;-----------------------------
;�X�e�[�W�N���A���𔭐�
;-----------------------------
CLEARSND:
	CALL	STEPSND_STOP
	JP	UHITSND

;-----------------------------
;���̃X�e�[�W��
;-----------------------------
NEXTSTAGE:
	CALL	UHITSND_STOP
	LD	D,0FFH
	CALL	TIMR2
	JP	Z0202

;-----------------------------
;���𔭐�
;IN	C=�r�b�g�p�^�[��
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
;�����~
;IN	C=�r�b�g�p�^�[��
;-----------------------------
STOPSND:
	LD	A,(SND)
	OR	C
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;�X�e�b�v���𔭐�
;-----------------------------
BGM:
	CALL	CLK1

	LD	C,00111111B	;=����������
	LD	A,(UFOCT)

	CP	30
	JR	NC,.L2
	SRL	C
	CP	20
	JR	NC,.L2
	SRL	C
	CP	10
	JR	NC,.L2
	SRL	C

.L2:	LD	A,(MACLK)
	AND	C
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

;�T�E���h������
	DW	0D6D0H
	DB	03H
	CALL	SNDINIT

;�o����
	DW	0D903H
	DB	06H
	CALL	UFOSND
	JP	CARWAIT

	DW	0D8FEH
	DB	03H
	CALL	UFOSND_STOP

;������
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

;�r�[�����ˉ�
	DW	0DACCH
	DB	04H
	CALL	SHOTSND
	RET

;ALIEN �q�b�g��
	DW	0DC02H
	DB	06H
	NOP
	NOP
	NOP
	CALL	HITSND

;INVADER �q�b�g��
	DW	0DC11H
	DB	06H
	NOP
	NOP
	NOP
	CALL	HITSND

;UFO �q�b�g��
	DW	0DBD8H
	DB	06H
	NOP
	NOP
	NOP
	CALL	HITSND

;�ʃN���A��
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

;END OF DATA
	DB	00H,00H,00H


SND:	DB	00H		;�|�[�g10H�ɏo�͂����l



