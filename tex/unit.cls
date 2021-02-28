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

\DeclareOption{es}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{en}{\booltrue{langEN}\boolfalse{langES}}
\DeclareOption{hdout}{\booltrue{modeHandout}}
\DeclareOption{pres}{\boolfalse{modeHandout}}


\DeclareOption*{%
  \ClassError{unit}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `unit' class}}
\ExecuteOptions{es}
\ProcessOptions*\relax

%% Class loading
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{english,spanish}{translator}
\PassOptionsToPackage{svgnames}{xcolor}
\PassOptionsToPackage{fleqn, tbtags, leqno}{amsmath}
\ifbool{modeHandout}{%
  \LoadClass[a4paper, 11pt]{article}
}{%
  \LoadClass[presentation, %
  compress, %% Navigation bars as small as possible
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
  \RequirePackage{docs-cclic}
}{%
  \RequirePackage{docs-presentation}%
}
\RequirePackage{docs-units}
\RequirePackage{docs-tables}
\RequirePackage{docs-envs}
\RequirePackage{docs-blocks}
\RequirePackage{docs-hyper}

\ifbool{modeHandout}{%
  \def\Hy@xspace@end{}
}{}
