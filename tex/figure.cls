%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{figure}[2019/09/08 v 0.1 Part of docs-bundle]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}

\DeclareOption{es}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{en}{\booltrue{langEN}\boolfalse{langES}}

\DeclareOption*{%
  \ClassError{figure}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `figure' class}}
\ExecuteOptions{es}
\ProcessOptions*\relax

%% Class loading
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{svgnames}{xcolor}
\PassOptionsToPackage{english, spanish}{translator}
\PassOptionsToPackage{fleqn, tbtags, leqno}{amsmath}
\LoadClass[12pt, tikz, crop]{standalone}


%% Load packages
%% --------------------------------------------------------------------------------
\RequirePackage{docs-base}
\RequirePackage{docs-math}
\RequirePackage{docs-colors}
\RequirePackage{docs-units}
\RequirePackage{docs-hyper}


\colorlet{colorIMg}{DarkBlue!70!Black}
\colorlet{colorIMe}{DarkBlue!70!White}
\colorlet{colorCMg}{DarkRed!70!Black}
\colorlet{colorCMe}{DarkRed!70!Yellow}
\colorlet{colorCMgLP}{DarkOrange!70!Black}
\colorlet{colorCMeLP}{DarkOrange}
\colorlet{colorR1}{Red!70!Black}
\colorlet{colorR2}{Blue!70!Black}
\colorlet{pmatfill}{Black!10!White}
\colorlet{proffill}{Gold!30!White}
\colorlet{deadfill}{Green!30!Yellow}
\colorlet{prodsurplus}{DarkSeaGreen!50!White}
\colorlet{conssurplus}{Khaki}
\colorlet{expendfill}{LightSalmon!50!White}
\colorlet{fillA}{LightSlateBlue}
\colorlet{fillB}{LightSteelBlue}
\colorlet{fillC}{LightPink}

\colorlet{betterfill}{PeachPuff!85!White}
\colorlet{worsefill}{Thistle!85!Black}


\usetikzlibrary{arrows.meta, babel, calc, hobby, intersections,
  matrix, positioning, backgrounds, decorations.markings,
  decorations.pathreplacing, spy, shapes.geometric, shapes.misc}

\tikzset{%
  tangent/.style={
    decoration={
      markings,% switch on markings
      mark= at position #1 with {
        \coordinate
        (tangent point-\pgfkeysvalueof{/pgf/decoration/mark info/sequence number}) at (0pt,0pt);
        \coordinate
        (tangent unit vector-\pgfkeysvalueof{/pgf/decoration/mark info/sequence number}) at  (1,0pt);
        \coordinate
        (tangent orthogonal unit vector-\pgfkeysvalueof{/pgf/decoration/mark info/sequence number}) at (0pt,1);
      }
    },
    postaction=decorate
  },
  use tangent/.style={
    shift=(tangent point-#1),
    x=(tangent unit vector-#1),
    y=(tangent orthogonal unit vector-#1)
  },
  use tangent/.default=1,
  colorA/.style={color = solarizedBlue!70!Black},
  colorB/.style={color = solarizedRed!70!Black},
  colorC/.style={color = solarizedGreen!70!Black},
  colorD/.style={color = solarizedOrange!70!Black},
  colorE/.style={color = solarizedViolet!70!Black},
  fillA/.style={color = solarizedCyan!25!White},
  fillB/.style={color = solarizedOrange!25!White},
  fillC/.style={color = solarizedGreen!25!White},
  axis/.style={very thick, <->, >=Stealth, line join=miter},
  curve label/.style={font=\small},
  curve/.style={very thick, every node/.style={black, curve label}},
  curve A/.style={very thick, colorA, every node/.style={black, curve label}},
  curve B/.style={very thick, colorB, every node/.style={black, curve label}},
  curve C/.style={very thick, colorC, every node/.style={black, curve label}},
  curve D/.style={very thick, colorD, every node/.style={black, curve label}},
  curve E/.style={very thick, colorE, every node/.style={black, curve label}},
  shaded/.style={opacity=0.4},
  help lines/.style = {thin, gray, every node/.style={black, curve label}},
  shift arrow/.style={%
    >=Stealth, thick, shorten >= 2pt, shorten <= 2pt,%
    colorC, every node/.style={black, curve label}},%
  dot/.style={circle,fill=black,minimum size=4pt,inner sep=0pt,outer sep=-1pt},
  nodot/.style={circle,minimum size=4pt,inner sep=0pt,outer sep=-1pt, transparent},
  IMg/.style={curve, color=colorIMg},
  IMe/.style={curve, color=colorIMe},
  CMg/.style={curve, color=colorCMg},
  CMe/.style={curve, color=colorCMe},
  CMgLP/.style={curve, color=colorCMgLP},
  CMeLP/.style={curve, color=colorCMeLP},
  R1/.style={curve, color=colorR1},
  R2/.style={curve, color=colorR2},
}

\def\MarkLt{4pt}
\def\MarkSep{2pt}

\tikzset{
  TwoMarks/.style={
    postaction={decorate,
      decoration={
        markings,
        mark=at position #1 with
          {
              \begin{scope}[xslant=0.2]
              \draw[line width=\MarkSep,white,-] (0pt,-\MarkLt) -- (0pt,\MarkLt) ;
              \draw[-] (-0.5*\MarkSep,-\MarkLt) -- (-0.5*\MarkSep,\MarkLt) ;
              \draw[-] (0.5*\MarkSep,-\MarkLt) -- (0.5*\MarkSep,\MarkLt) ;
              \end{scope}
          }
       }
    }
  },
  TwoMarks/.default={0.5},
}

\newdimen\multi@col@width
\newdimen\multi@col@margin
\newcount\multi@col@count
\multi@col@width=0pt

\tikzset{%
  multicol/.code={%
    \global\multi@col@count=#1\relax
    \global\let\orig@pgfmatrixendcode=\pgfmatrixendcode
    \global\let\orig@pgfmatrixemptycode=\pgfmatrixemptycode
    \def\pgfmatrixendcode##1{\orig@pgfmatrixendcode%
      ##1%
      \pgfutil@tempdima=\pgf@picmaxx
      \global\multi@col@margin=\pgf@picminx
      \advance\pgfutil@tempdima by -\pgf@picminx
      \divide\pgfutil@tempdima by #1\relax
      \global\multi@col@width=\pgfutil@tempdima
      \pgf@picmaxx=.5\multi@col@width
      \pgf@picminx=-.5\multi@col@width
      \global\pgf@picmaxx=\pgf@picmaxx
      \global\pgf@picminx=\pgf@picminx
      \gdef\multi@adjust@position{%
        \setbox\pgf@matrix@cell=\hbox\bgroup
        \hfil\hskip-1.5\multi@col@margin
        \hfil\hskip-.5\multi@col@width
        \box\pgf@matrix@cell
        \egroup
      }%
      \gdef\multi@temp{\aftergroup\multi@adjust@position}%
      \aftergroup\multi@temp
    }
    \gdef\pgfmatrixemptycode{%
      \orig@pgfmatrixemptycode
      \global\advance\multi@col@count by -1\relax
      \global\pgf@picmaxx=.5\multi@col@width
      \global\pgf@picminx=-.5\multi@col@width
      \ifnum\multi@col@count=1\relax
       \global\let\pgfmatrixemptycode=\orig@pgfmatrixemptycode
      \fi
    }
  }
}
