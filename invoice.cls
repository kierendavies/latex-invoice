\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{invoice}
\LoadClass[a4paper]{scrlttr2}

% Pretty dates
\usepackage[english]{babel}
\usepackage[english]{isodate}
\cleanlookdateon

% Layout options
\KOMAoptions{
  fromalign=left,
  fromrule=afteraddress,
  backaddress=false,
	foldmarks=false,
}

% Default fields
\setkomavar{fromaddress}{\vspace{-\baselineskip}}
\setkomavar{title}{Invoice}
\newkomavar{frombankbank}
\newkomavar{frombankaccount}
\newkomavar{frombankbranchcode}

% Descriptions and icons
\usepackage{fontawesome}
\newcommand{\fwicon}[1]{\makebox[1em][c]{#1}}
\setkomavar*{fromphone}{\fwicon{\faPhone}~}
\setkomavar*{frommobilephone}{\fwicon{\faMobile}~}
\setkomavar*{fromemail}{\fwicon{\faEnvelopeO}~}
\setkomavar*{fromurl}{\fwicon{\faGlobe}~}
\setkomavar*{frombank}{Payable to}

% Put title about reference line
\makeatletter
\@addtoplength{firstfootvpos}{-3cm}
\@setplength{firstfootwidth}{\textwidth}
\@addtoplength{refvpos}{1cm}
\@setplength{refaftervskip}{-2.5cm}
\makeatother
\setkomavar{subject}{\relax}

% Invoice environment
\usepackage{longtable}
\usepackage{dcolumn}
\newcolumntype{q}[1]{>{\raggedright\setlength{\hangindent}{1em}}p{#1}}
\newcolumntype{d}{D{.}{.}{2}}
\newkomavar{invoicetotal}
\newenvironment{invoice}{
	\ignorespaces
	\renewcommand{\item}[4]{##1&##2&##3&##4\\}
	\newcommand{\total}[1]{\\\hline\hline\textbf{Total}&&&##1}
	\setlength\LTleft{0pt}
	\setlength\LTright{0pt}
	\begin{longtable}{@{\extracolsep{\fill}}q{7cm}rdd}
	  \textbf{Description} &
		\multicolumn{1}{r}{\textbf{Quantity}} &
		\multicolumn{1}{r}{\textbf{Unit Price}} &
		\multicolumn{1}{r}{\textbf{Amount}} \\
		\hline
	  \endhead
}{
	\end{longtable}
}

\AtBeginDocument{
	% Enable display of non-empty fields
	\ifkomavarempty{fromlogo}{}{\KOMAoptions{fromlogo}}
	\ifkomavarempty{fromphone}{}{\KOMAoptions{fromphone}}
	\ifkomavarempty{frommobilephone}{}{\KOMAoptions{frommobilephone}}
	\ifkomavarempty{fromemail}{}{\KOMAoptions{fromemail}}
	\ifkomavarempty{fromurl}{}{\KOMAoptions{fromurl}}
	\setkomavar{frombank}{%
		\begin{tabular}{@{}ll@{}}
			\ifkomavarempty{frombankbank}{}{%
				Bank & \usekomavar{frombankbank} \\
			}
			\ifkomavarempty{frombankaccount}{}{%
				Acc.{} no.{} & \usekomavar{frombankaccount} \\
			}
			\ifkomavarempty{frombankbranchcode}{}{%
				Branch code & \usekomavar{frombankbranchcode} \\
			}
		\end{tabular}
	}
  \ifkomavarempty{frombank}{}{
    \setkomavar{firstfoot}{%
      \textbf{\usekomavar*{frombank}} \\[6pt]
      \usekomavar{frombank}
    }
  }

	\begin{letter}{}
	\opening{}
	\begin{invoice}
}

\AtEndDocument{
	\end{invoice}
	\end{letter}
}
