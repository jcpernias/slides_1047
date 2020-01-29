%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{unit}[2018/11/10 v 0.1 Part of docs-bundle]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}
\newbool{modeHandout}

\DeclareOption{Spanish}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{English}{\booltrue{langEN}\boolfalse{langES}}
\DeclareOption{Handout}{\booltrue{modeHandout}}
\DeclareOption{Presentation}{\boolfalse{modeHandout}}


\DeclareOption*{%
  \ClassError{slides}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `unit' class}}
\ExecuteOptions{Spanish}
\ProcessOptions*\relax

%% Class loading
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{english,spanish}{translator}
\PassOptionsToPackage{svgnames}{xcolor}
\PassOptionsToPackage{fleqn, tbtags, leqno}{amsmath}
\ifbool{modeHandout}{%
  \LoadClass[a4paper, 11pt]{article}
  % \RequirePackage[hyperref]{beamerarticle}%
}{%
  \LoadClass[presentation, %
  compress, %% Navigation bars as small as possible
  hyperref, %
  % fleqn, tbtags, leqno, %% amsmath options
  11pt %
  ]{beamer}%
}  


%% Load packages
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{document}{ragged2e}
\RequirePackage{docs-base}
\RequirePackage{docs-math}
\RequirePackage{docs-colors}
\ifbool{modeHandout}{%
  \RequirePackage{docs-handout}%
  \RequirePackage{docs-units}
  \RequirePackage{docs-tables}
  \RequirePackage{docs-envs}
  \RequirePackage{docs-blocks}
  \RequirePackage{docs-cclic}
  \RequirePackage{docs-hyper}
  \makeatletter\def\Hy@xspace@end{}\makeatother
  %\newcommand*{\hypersetup}[1]{}%
}{%
  \RequirePackage{docs-presentation}%
  \RequirePackage{docs-units}
  \RequirePackage{docs-tables}
  \RequirePackage{docs-envs}
  \RequirePackage{docs-blocks}
  \RequirePackage{docs-hyper}
}
\ifbool{modeHandout}{%
}{}

