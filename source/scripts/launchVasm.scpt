FasdUAS 1.101.10   ��   ��    k             j     �� �� 0 myprocessid myProcessId  m     ����      	  l     �� 
 ��   
  set myProcessId to 1     �   ( s e t   m y P r o c e s s I d   t o   1 	     l    Z ����  Z     Z  ��   =         o     ���� 0 myprocessid myProcessId  m    ����    O   
 *    k    )       I   ������
�� .miscactvnull��� ��� null��  ��        I   �� ��
�� .coredoscnull��� ��� ctxt  m       �     $ A M I D E V / m a k e f i l e��         l   �� ! "��   ! ) #		set myProcessId to do script "ps"    " � # # F 	 	 s e t   m y P r o c e s s I d   t o   d o   s c r i p t   " p s "    $ % $ l   �� & '��   & &  		set str to myProcessId as text    ' � ( ( @ 	 	 s e t   s t r   t o   m y P r o c e s s I d   a s   t e x t %  ) * ) l   �� + ,��   + b \do shell script "ps -ax | awk '{$2=\"\";$3=\"\";$4=\"\";print}' | grep -Eo -m1 '[0-9]{1,6}'"    , � - - � d o   s h e l l   s c r i p t   " p s   - a x   |   a w k   ' { $ 2 = \ " \ " ; $ 3 = \ " \ " ; $ 4 = \ " \ " ; p r i n t } '   |   g r e p   - E o   - m 1   ' [ 0 - 9 ] { 1 , 6 } ' " *  . / . l   �� 0 1��   0 E ?		do shell script "ps -ax | grep -E -m1 'ttys000' | cut -c1-5'"    1 � 2 2 ~ 	 	 d o   s h e l l   s c r i p t   " p s   - a x   |   g r e p   - E   - m 1   ' t t y s 0 0 0 '   |   c u t   - c 1 - 5 ' " /  3 4 3 I   �� 5��
�� .coredoscnull��� ��� ctxt 5 m     6 6 � 7 7 6 p s   - a x   |   g r e p   - m 1   ' t t y s 0 0 0 '��   4  8 9 8 r     ' : ; : l    ! <���� < 1     !��
�� 
rslt��  ��   ; o      ���� 0 myprocessid myProcessId 9  =�� = l  ( (�� > ?��   > ( "display dialog myProcessId as text    ? � @ @ D d i s p l a y   d i a l o g   m y P r o c e s s I d   a s   t e x t��    m   
  A A�                                                                                      @ alis    J  Macintosh HD               ���BD ����Terminal.app                                                   �������        ����  
 cu             	Utilities   -/:System:Applications:Utilities:Terminal.app/     T e r m i n a l . a p p    M a c i n t o s h   H D  *System/Applications/Utilities/Terminal.app  / ��  ��    Q   - Z B C D B k   0 K E E  F G F l  0 0��������  ��  ��   G  H�� H O   0 K I J I k   4 J K K  L M L r   4 D N O N m   4 5��
�� boovtrue O 6  5 C P Q P n   5 : R S R 1   8 :��
�� 
pisf S l  5 8 T���� T 2   5 8��
�� 
prcs��  ��   Q =  ; B U V U 1   < >��
�� 
idux V m   ? A����7 M  W X W l  E E�� Y Z��   Y " do script "$AMIDEV/makefile"    Z � [ [ 8 d o   s c r i p t   " $ A M I D E V / m a k e f i l e " X  \�� \ I  E J�� ]��
�� .miscdoscnull���     **** ] m   E F ^ ^ � _ _  l s��  ��   J m   0 1 ` `�                                                                                  sevs  alis    \  Macintosh HD               ���BD ����System Events.app                                              �������        ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  ��   C R      ������
�� .ascrerr ****      � ****��  ��   D r   S Z a b a m   S T����   b o      ���� 0 myprocessid myProcessId��  ��     c�� c l     ��������  ��  ��  ��       �� d e f��   d ������ 0 myprocessid myProcessId
�� .aevtoappnull  �   � **** e  g g  h���� h  A������
�� 
cwin��f�
�� kfrmID  
�� 
ttab��  f �� i���� j k��
�� .aevtoappnull  �   � **** i k     Z l l  ����  ��  ��   j   k  A�� �� 6�� `���� m���� ^������
�� .miscactvnull��� ��� null
�� .coredoscnull��� ��� ctxt
�� 
rslt
�� 
prcs
�� 
pisf m  
�� 
idux��7
�� .miscdoscnull���     ****��  ��  �� [b   j  %� *j O�j O�j O�Ec   OPUY /  � e*�-�,�[�,\Z�81FO�j UW X  jEc    ascr  ��ޭ