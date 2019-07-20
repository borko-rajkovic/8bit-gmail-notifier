/*
 * PWM_music_notes.inc
 *
 *		Date: 09.01.2016 15:58:11
 *		Author: Borko Rajkovic
 * 
 *		Input Capture Register (ICR) values for AVR MCU to create sounds with PWM
 *		
 *		Clock:   		8000000 [Hz]
 *		Prescaler:      8
 *		PWM mode:       phase/frequency correct 16 bit
 *		
 *		freq = fclk/(2*N*TOP) ; N-prescaler; TOP = ICR
 *		ICR = fclk/(2*N*freq) ; freq - desired frequency
 *
 *		Example - tone F2 (frequency is 87,31Hz):
 *
 *		   ICR = 8MHz(2*8*87,31)=5726,72 ~ 5727
 *
 *			freq = 8MHz(2*8*5727)=87,3057 Hz ~ 87,31 Hz
 *
 *			Error = (87,3057/87,31 - 1)*100 = 0,004%
 * 
 */ 

.nolist

#ifndef __PWM_NOTES_H__
#define __PWM_NOTES_H__

/* Pause */
.equ P = 1

/* end */
.equ MUSIC_END  = 0

/* Octave #2 */

.equ A2			=	4545	 	/* PWM: 110.01 Hz, note freq: 110.00 Hz, error 0.01% */
.equ A2b		=	4816	 	/* PWM: 103.82 Hz, note freq: 103.83 Hz, error 0.01% */
.equ a2x		=	4290	 	/* PWM: 116.55 Hz, note freq: 116.54 Hz, error 0.01% */
.equ ais2		=	4290	 	/* PWM: 116.55 Hz, note freq: 116.54 Hz, error 0.01% */
.equ b2			=	4050	 	/* PWM: 123.46 Hz, note freq: 123.47 Hz, error 0.01% */
.equ b2b		=	4290	 	/* PWM: 116.55 Hz, note freq: 116.54 Hz, error 0.01% */
.equ c2			=	7645	 	/* PWM:  65.40 Hz, note freq:  65.41 Hz, error 0.01% */
.equ c2x		=	7215	 	/* PWM:  69.30 Hz, note freq:  69.30 Hz, error 0.01% */
.equ cis2		=	7215	 	/* PWM:  69.30 Hz, note freq:  69.30 Hz, error 0.01% */
.equ d2			=	6810	 	/* PWM:  73.42 Hz, note freq:  73.42 Hz, error 0.01% */
.equ d2b		=	7215	 	/* PWM:  69.30 Hz, note freq:  69.30 Hz, error 0.01% */
.equ d2x		=	6428	 	/* PWM:  77.78 Hz, note freq:  77.78 Hz, error 0.00% */
.equ dis2		=	6428	 	/* PWM:  77.78 Hz, note freq:  77.78 Hz, error 0.00% */
.equ E2			=	6067	 	/* PWM:  82.41 Hz, note freq:  82.41 Hz, error 0.01% */
.equ E2b		=	6428	 	/* PWM:  77.78 Hz, note freq:  77.78 Hz, error 0.00% */
.equ F2			=	5727	 	/* PWM:  87.31 Hz, note freq:  87.31 Hz, error 0.00% */
.equ F2x		=	5405	 	/* PWM:  92.51 Hz, note freq:  92.50 Hz, error 0.01% */
.equ Fis2		=	5405	 	/* PWM:  92.51 Hz, note freq:  92.50 Hz, error 0.01% */
.equ G2			=	5102	 	/* PWM:  98.00 Hz, note freq:  98.00 Hz, error 0.00% */
.equ G2b		=	5405	 	/* PWM:  92.51 Hz, note freq:  92.50 Hz, error 0.01% */
.equ G2x		=	4816	 	/* PWM: 103.82 Hz, note freq: 103.83 Hz, error 0.01% */
.equ Gis2		=	4816	 	/* PWM: 103.82 Hz, note freq: 103.83 Hz, error 0.01% */
.equ H2			=	4050	 	/* PWM: 123.46 Hz, note freq: 123.47 Hz, error 0.01% */
.equ H2b		=	4290	 	/* PWM: 116.55 Hz, note freq: 116.54 Hz, error 0.01% */
.equ bH2		=	4290	 	/* PWM: 116.55 Hz, note freq: 116.54 Hz, error 0.01% */
.equ xA2		=	4290	 	/* PWM: 116.55 Hz, note freq: 116.54 Hz, error 0.01% */
.equ xC2		=	7215	 	/* PWM:  69.30 Hz, note freq:  69.30 Hz, error 0.01% */
.equ xF2		=	5405	 	/* PWM:  92.51 Hz, note freq:  92.50 Hz, error 0.01% */
.equ xG2		=	5102	 	/* PWM:  98.00 Hz, note freq:  98.00 Hz, error 0.00% */

/* Octave #3 */

.equ A3			=	2273	 	/* PWM: 219.97 Hz, note freq: 220.00 Hz, error 0.01% */
.equ A3b		=	2408	 	/* PWM: 207.64 Hz, note freq: 207.65 Hz, error 0.01% */
.equ A3x		=	2145	 	/* PWM: 233.10 Hz, note freq: 233.08 Hz, error 0.01% */
.equ Ais3		=	2145	 	/* PWM: 233.10 Hz, note freq: 233.08 Hz, error 0.01% */
.equ B3			=	2025	 	/* PWM: 246.91 Hz, note freq: 246.94 Hz, error 0.01% */
.equ B3b		=	2145	 	/* PWM: 233.10 Hz, note freq: 233.08 Hz, error 0.01% */
.equ C3			=	3822	 	/* PWM: 130.82 Hz, note freq: 130.81 Hz, error 0.01% */
.equ C3x		=	3608	 	/* PWM: 138.58 Hz, note freq: 138.59 Hz, error 0.01% */
.equ Cis3		=	3608	 	/* PWM: 138.58 Hz, note freq: 138.59 Hz, error 0.01% */
.equ D3			=	3405	 	/* PWM: 146.84 Hz, note freq: 146.83 Hz, error 0.01% */
.equ D3b		=	3608	 	/* PWM: 138.58 Hz, note freq: 138.59 Hz, error 0.01% */
.equ D3x		=	3214	 	/* PWM: 155.57 Hz, note freq: 155.56 Hz, error 0.00% */
.equ Dis3		=	3214	 	/* PWM: 155.57 Hz, note freq: 155.56 Hz, error 0.00% */
.equ E3			=	3034	 	/* PWM: 164.80 Hz, note freq: 164.81 Hz, error 0.01% */
.equ E3b		=	3214	 	/* PWM: 155.57 Hz, note freq: 155.56 Hz, error 0.00% */
.equ F3			=	2863	 	/* PWM: 174.64 Hz, note freq: 174.61 Hz, error 0.02% */
.equ F3x		=	2703	 	/* PWM: 184.98 Hz, note freq: 185.00 Hz, error 0.01% */
.equ Fis3		=	2703	 	/* PWM: 184.98 Hz, note freq: 185.00 Hz, error 0.01% */
.equ G3			=	2551	 	/* PWM: 196.00 Hz, note freq: 196.00 Hz, error 0.00% */
.equ G3b		=	2703	 	/* PWM: 184.98 Hz, note freq: 185.00 Hz, error 0.01% */
.equ G3x		=	2408	 	/* PWM: 207.64 Hz, note freq: 207.65 Hz, error 0.01% */
.equ Gis3		=	2408	 	/* PWM: 207.64 Hz, note freq: 207.65 Hz, error 0.01% */
.equ H3			=	2025	 	/* PWM: 246.91 Hz, note freq: 246.94 Hz, error 0.01% */
.equ H3b		=	2145	 	/* PWM: 233.10 Hz, note freq: 233.08 Hz, error 0.01% */
.equ bH3		=	2145	 	/* PWM: 233.10 Hz, note freq: 233.08 Hz, error 0.01% */
.equ xA3		=	2145	 	/* PWM: 233.10 Hz, note freq: 233.08 Hz, error 0.01% */
.equ xC3		=	3608	 	/* PWM: 138.58 Hz, note freq: 138.59 Hz, error 0.01% */
.equ xF3		=	2703	 	/* PWM: 184.98 Hz, note freq: 185.00 Hz, error 0.01% */
.equ xG3		=	2551	 	/* PWM: 196.00 Hz, note freq: 196.00 Hz, error 0.00% */

/* Octave #4 */

.equ A4			=	1136	 	/* PWM: 440.14 Hz, note freq: 440.00 Hz, error 0.03% */
.equ A4b		=	1204	 	/* PWM: 415.28 Hz, note freq: 415.30 Hz, error 0.01% */
.equ A4x		=	1073	 	/* PWM: 465.98 Hz, note freq: 466.16 Hz, error 0.04% */
.equ Ais4		=	1073	 	/* PWM: 465.98 Hz, note freq: 466.16 Hz, error 0.04% */
.equ B4			=	1012	 	/* PWM: 494.07 Hz, note freq: 493.88 Hz, error 0.04% */
.equ B4b		=	1073	 	/* PWM: 465.98 Hz, note freq: 466.16 Hz, error 0.04% */
.equ C4			=	1911	 	/* PWM: 261.64 Hz, note freq: 261.63 Hz, error 0.01% */
.equ C4x		=	1804	 	/* PWM: 277.16 Hz, note freq: 277.18 Hz, error 0.01% */
.equ Cis4		=	1804	 	/* PWM: 277.16 Hz, note freq: 277.18 Hz, error 0.01% */
.equ D4			=	1703	 	/* PWM: 293.60 Hz, note freq: 293.66 Hz, error 0.02% */
.equ D4b		=	1804	 	/* PWM: 277.16 Hz, note freq: 277.18 Hz, error 0.01% */
.equ D4x		=	1607	 	/* PWM: 311.14 Hz, note freq: 311.13 Hz, error 0.00% */
.equ Dis4		=	1607	 	/* PWM: 311.14 Hz, note freq: 311.13 Hz, error 0.00% */
.equ E4			=	1517	 	/* PWM: 329.60 Hz, note freq: 329.63 Hz, error 0.01% */
.equ E4b		=	1607	 	/* PWM: 311.14 Hz, note freq: 311.13 Hz, error 0.00% */
.equ F4			=	1432	 	/* PWM: 349.16 Hz, note freq: 349.23 Hz, error 0.02% */
.equ F4x		=	1351	 	/* PWM: 370.10 Hz, note freq: 369.99 Hz, error 0.03% */
.equ Fis4		=	1351	 	/* PWM: 370.10 Hz, note freq: 369.99 Hz, error 0.03% */
.equ G4			=	1276	 	/* PWM: 391.85 Hz, note freq: 392.00 Hz, error 0.04% */
.equ G4b		=	1351	 	/* PWM: 370.10 Hz, note freq: 369.99 Hz, error 0.03% */
.equ G4x		=	1204	 	/* PWM: 415.28 Hz, note freq: 415.30 Hz, error 0.01% */
.equ Gis4		=	1204	 	/* PWM: 415.28 Hz, note freq: 415.30 Hz, error 0.01% */
.equ H4			=	1012	 	/* PWM: 494.07 Hz, note freq: 493.88 Hz, error 0.04% */
.equ H4b		=	1073	 	/* PWM: 465.98 Hz, note freq: 466.16 Hz, error 0.04% */
.equ bH4		=	1073	 	/* PWM: 465.98 Hz, note freq: 466.16 Hz, error 0.04% */
.equ xA4		=	1073	 	/* PWM: 465.98 Hz, note freq: 466.16 Hz, error 0.04% */
.equ xC4		=	1804	 	/* PWM: 277.16 Hz, note freq: 277.18 Hz, error 0.01% */
.equ xF4		=	1351	 	/* PWM: 370.10 Hz, note freq: 369.99 Hz, error 0.03% */
.equ xG4		=	1276	 	/* PWM: 391.85 Hz, note freq: 392.00 Hz, error 0.04% */

/* Octave #5 */

.equ A5			=	568	  		/* PWM: 880.28 Hz, note freq: 880.00 Hz, error 0.03% */
.equ A5b		=	602	  		/* PWM: 830.56 Hz, note freq: 830.61 Hz, error 0.01% */
.equ A5x		=	536	  		/* PWM: 932.84 Hz, note freq: 932.33 Hz, error 0.05% */
.equ Ais5		=	536	  		/* PWM: 932.84 Hz, note freq: 932.33 Hz, error 0.05% */
.equ B5			=	506	  		/* PWM: 988.14 Hz, note freq: 987.77 Hz, error 0.04% */
.equ B5b		=	536	  		/* PWM: 932.84 Hz, note freq: 932.33 Hz, error 0.05% */
.equ C5			=	956	  		/* PWM: 523.01 Hz, note freq: 523.25 Hz, error 0.05% */
.equ C5x		=	902	  		/* PWM: 554.32 Hz, note freq: 554.37 Hz, error 0.01% */
.equ Cis5		=	902	  		/* PWM: 554.32 Hz, note freq: 554.37 Hz, error 0.01% */
.equ D5			=	851	  		/* PWM: 587.54 Hz, note freq: 587.33 Hz, error 0.04% */
.equ D5b		=	902	  		/* PWM: 554.32 Hz, note freq: 554.37 Hz, error 0.01% */
.equ D5x		=	804	  		/* PWM: 621.89 Hz, note freq: 622.25 Hz, error 0.06% */
.equ Dis5		=	804	  		/* PWM: 621.89 Hz, note freq: 622.25 Hz, error 0.06% */
.equ E5			=	758	  		/* PWM: 659.63 Hz, note freq: 659.26 Hz, error 0.06% */
.equ E5b		=	804	  		/* PWM: 621.89 Hz, note freq: 622.25 Hz, error 0.06% */
.equ F5			=	716	  		/* PWM: 698.32 Hz, note freq: 698.46 Hz, error 0.02% */
.equ F5x		=	676	  		/* PWM: 739.64 Hz, note freq: 739.99 Hz, error 0.05% */
.equ Fis5		=	676	  		/* PWM: 739.64 Hz, note freq: 739.99 Hz, error 0.05% */
.equ G5			=	638	  		/* PWM: 783.70 Hz, note freq: 783.99 Hz, error 0.04% */
.equ G5b		=	676	  		/* PWM: 739.64 Hz, note freq: 739.99 Hz, error 0.05% */
.equ G5x		=	602	  		/* PWM: 830.56 Hz, note freq: 830.61 Hz, error 0.01% */
.equ Gis5		=	602	  		/* PWM: 830.56 Hz, note freq: 830.61 Hz, error 0.01% */
.equ H5			=	506	  		/* PWM: 988.14 Hz, note freq: 987.77 Hz, error 0.04% */
.equ H5b		=	536	  		/* PWM: 932.84 Hz, note freq: 932.33 Hz, error 0.05% */
.equ bH5		=	536	  		/* PWM: 932.84 Hz, note freq: 932.33 Hz, error 0.05% */
.equ xA5		=	536	  		/* PWM: 932.84 Hz, note freq: 932.33 Hz, error 0.05% */
.equ xC5		=	902	  		/* PWM: 554.32 Hz, note freq: 554.37 Hz, error 0.01% */
.equ xF5		=	676	  		/* PWM: 739.64 Hz, note freq: 739.99 Hz, error 0.05% */
.equ xG5		=	638	  		/* PWM: 783.70 Hz, note freq: 783.99 Hz, error 0.04% */

/* Octave #6 */

.equ A6			=	284	  		/* PWM: 1760.56 Hz, note freq: 1760.00 Hz, error 0.03% */
.equ A6b		=	301	  		/* PWM: 1661.13 Hz, note freq: 1661.22 Hz, error 0.01% */
.equ A6x		=	268	  		/* PWM: 1865.67 Hz, note freq: 1864.66 Hz, error 0.05% */
.equ Ais6		=	268	  		/* PWM: 1865.67 Hz, note freq: 1864.66 Hz, error 0.05% */
.equ B6			=	253	  		/* PWM: 1976.28 Hz, note freq: 1975.53 Hz, error 0.04% */
.equ B6b		=	268	  		/* PWM: 1865.67 Hz, note freq: 1864.66 Hz, error 0.05% */
.equ C6			=	478	  		/* PWM: 1046.03 Hz, note freq: 1046.50 Hz, error 0.05% */
.equ C6x		=	451	  		/* PWM: 1108.65 Hz, note freq: 1108.73 Hz, error 0.01% */
.equ Cis6		=	451	  		/* PWM: 1108.65 Hz, note freq: 1108.73 Hz, error 0.01% */
.equ D6			=	426	  		/* PWM: 1173.71 Hz, note freq: 1174.66 Hz, error 0.08% */
.equ D6b		=	451	  		/* PWM: 1108.65 Hz, note freq: 1108.73 Hz, error 0.01% */
.equ D6x		=	402	  		/* PWM: 1243.78 Hz, note freq: 1244.51 Hz, error 0.06% */
.equ Dis6		=	402	  		/* PWM: 1243.78 Hz, note freq: 1244.51 Hz, error 0.06% */
.equ E6			=	379	  		/* PWM: 1319.26 Hz, note freq: 1318.51 Hz, error 0.06% */
.equ E6b		=	402	  		/* PWM: 1243.78 Hz, note freq: 1244.51 Hz, error 0.06% */
.equ F6			=	358	  		/* PWM: 1396.65 Hz, note freq: 1396.91 Hz, error 0.02% */
.equ F6x		=	338	  		/* PWM: 1479.29 Hz, note freq: 1479.98 Hz, error 0.05% */
.equ Fis6		=	338	  		/* PWM: 1479.29 Hz, note freq: 1479.98 Hz, error 0.05% */
.equ G6			=	319	  		/* PWM: 1567.40 Hz, note freq: 1567.98 Hz, error 0.04% */
.equ G6b		=	338	  		/* PWM: 1479.29 Hz, note freq: 1479.98 Hz, error 0.05% */
.equ G6x		=	301	  		/* PWM: 1661.13 Hz, note freq: 1661.22 Hz, error 0.01% */
.equ Gis6		=	301	  		/* PWM: 1661.13 Hz, note freq: 1661.22 Hz, error 0.01% */
.equ H6			=	253	  		/* PWM: 1976.28 Hz, note freq: 1975.53 Hz, error 0.04% */
.equ H6b		=	268	  		/* PWM: 1865.67 Hz, note freq: 1864.66 Hz, error 0.05% */
.equ bH6		=	268	  		/* PWM: 1865.67 Hz, note freq: 1864.66 Hz, error 0.05% */
.equ xA6		=	268	  		/* PWM: 1865.67 Hz, note freq: 1864.66 Hz, error 0.05% */
.equ xC6		=	451	  		/* PWM: 1108.65 Hz, note freq: 1108.73 Hz, error 0.01% */
.equ xF6		=	338	  		/* PWM: 1479.29 Hz, note freq: 1479.98 Hz, error 0.05% */
.equ xG6		=	319	  		/* PWM: 1567.40 Hz, note freq: 1567.98 Hz, error 0.04% */

/* Octave #7 */

.equ A7			=	142	  		/* PWM: 3521.13 Hz, note freq: 3520.00 Hz, error 0.03% */
.equ A7b		=	150	  		/* PWM: 3333.33 Hz, note freq: 3322.44 Hz, error 0.33% */
.equ A7x		=	134	  		/* PWM: 3731.34 Hz, note freq: 3729.31 Hz, error 0.05% */
.equ Ais7		=	134	  		/* PWM: 3731.34 Hz, note freq: 3729.31 Hz, error 0.05% */
.equ B7			=	127	  		/* PWM: 3937.01 Hz, note freq: 3951.07 Hz, error 0.36% */
.equ B7b		=	134	  		/* PWM: 3731.34 Hz, note freq: 3729.31 Hz, error 0.05% */
.equ C7			=	239	  		/* PWM: 2092.05 Hz, note freq: 2093.00 Hz, error 0.05% */
.equ C7x		=	225	  		/* PWM: 2222.22 Hz, note freq: 2217.46 Hz, error 0.21% */
.equ Cis7		=	225	  		/* PWM: 2222.22 Hz, note freq: 2217.46 Hz, error 0.21% */
.equ D7			=	213	  		/* PWM: 2347.42 Hz, note freq: 2349.32 Hz, error 0.08% */
.equ D7b		=	225	  		/* PWM: 2222.22 Hz, note freq: 2217.46 Hz, error 0.21% */
.equ D7x		=	201	  		/* PWM: 2487.56 Hz, note freq: 2489.02 Hz, error 0.06% */
.equ Dis7		=	201	  		/* PWM: 2487.56 Hz, note freq: 2489.02 Hz, error 0.06% */
.equ E7			=	190	  		/* PWM: 2631.58 Hz, note freq: 2637.02 Hz, error 0.21% */
.equ E7b		=	201	  		/* PWM: 2487.56 Hz, note freq: 2489.02 Hz, error 0.06% */
.equ F7			=	179	  		/* PWM: 2793.30 Hz, note freq: 2793.83 Hz, error 0.02% */
.equ F7x		=	169	  		/* PWM: 2958.58 Hz, note freq: 2959.96 Hz, error 0.05% */
.equ Fis7		=	169	  		/* PWM: 2958.58 Hz, note freq: 2959.96 Hz, error 0.05% */
.equ G7			=	159	  		/* PWM: 3144.65 Hz, note freq: 3135.96 Hz, error 0.28% */
.equ G7b		=	169	  		/* PWM: 2958.58 Hz, note freq: 2959.96 Hz, error 0.05% */
.equ G7x		=	150	  		/* PWM: 3333.33 Hz, note freq: 3322.44 Hz, error 0.33% */
.equ Gis7		=	150	  		/* PWM: 3333.33 Hz, note freq: 3322.44 Hz, error 0.33% */
.equ H7			=	127	  		/* PWM: 3937.01 Hz, note freq: 3951.07 Hz, error 0.36% */
.equ H7b		=	134	  		/* PWM: 3731.34 Hz, note freq: 3729.31 Hz, error 0.05% */
.equ bH7		=	134	  		/* PWM: 3731.34 Hz, note freq: 3729.31 Hz, error 0.05% */
.equ xA7		=	134	  		/* PWM: 3731.34 Hz, note freq: 3729.31 Hz, error 0.05% */
.equ xC7		=	225	  		/* PWM: 2222.22 Hz, note freq: 2217.46 Hz, error 0.21% */
.equ xF7		=	169	  		/* PWM: 2958.58 Hz, note freq: 2959.96 Hz, error 0.05% */
.equ xG7		=	159	  		/* PWM: 3144.65 Hz, note freq: 3135.96 Hz, error 0.28% */

#endif

.list
