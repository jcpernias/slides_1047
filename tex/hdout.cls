%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{hdout}[2021/07/18 v 0.1]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}

\DeclareOption{es}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{en}{\booltrue{langEN}\boolfalse{langES}}


\DeclareOption*{%
  \ClassError{hdout}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `hdout' class}}
\ExecuteOptions{es}
\ProcessOptions*\relax

%% Class loading
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{english,spanish}{translator}
\PassOptionsToPackage{svgnames}{xcolor}
\PassOptionsToPackage{fleqn, tbtags, leqno}{amsmath}
\LoadClass[a4paper, 11pt]{article}
\RequirePackage{beamerarticle}


%% Load packages
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{document}{ragged2e}
\RequirePackage{docs-base}
\RequirePackage{docs-math}
\RequirePackage{docs-colors}
\RequirePackage{docs-handout}%
\RequirePackage{docs-cclic}
\RequirePackage{docs-units}
\RequirePackage{docs-tables}
\RequirePackage{docs-envs}
\RequirePackage{docs-blocks}
\RequirePackage{docs-hyper}

\def\Hy@xspace@end{}
