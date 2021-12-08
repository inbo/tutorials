---
title: "Books and articles on statistics"
date: 2018-03-21
csl: download.file("https://github.com/citation-style-language/styles/raw/master/research-institute-for-nature-and-forest.csl", tempfile())
bibliography: ../reproducible_research.bib
categories: ["literature"]
tags: ["literature", "open science"]
output: 
    md_document:
        preserve_yaml: true
---

-   McElreath (2015): Statistical Rethinking is an introduction to
    applied Bayesian data analysis, aimed at PhD students and
    researchers in the natural and social sciences. This audience has
    had some calculus and linear algebra, and one or two joyless
    undergraduate courses in statistics. I've been teaching applied
    statistics to this audience for about a decade now, and this book
    has evolved from that experience. The book teaches generalized
    linear multilevel modeling (GLMMs) from a Bayesian perspective,
    relying on a simple logical interpretation of Bayesian probability
    and maximum entropy. The book covers the basics of regression
    through multilevel models, as well as touching on measurement error,
    missing data, and Gaussian process models for spatial and network
    autocorrelation. This is not a traditional mathematical statistics
    book. Instead the approach is computational, using complete R code
    examples, aimed at developing skilled and skeptical scientists.
    Theory is explained through simulation exercises, using R code. And
    modeling examples are fully worked, with R code displayed within the
    main text. Mathematical depth is given in optional
    {"}overthinking{"} boxes throughout.

-   Kass *et al.* (2016): The authors propose a set of 10 simple rules
    for effective statistical practice

-   Quinn & Keough (2002): An essential textbook for any student or
    researcher in biology needing to design experiments, sample programs
    or analyse the resulting data. The text begins with a revision of
    estimation and hypothesis testing methods, covering both classical
    and Bayesian philosophies, before advancing to the analysis of
    linear and generalized linear models. Topics covered include linear
    and logistic regression, simple and complex ANOVA models (for
    factorial, nested, block, split-plot and repeated measures and
    covariance designs), and log-linear models. Multivariate techniques,
    including classification and ordination, are then introduced.
    Special emphasis is placed on checking assumptions, exploratory data
    analysis and presentation of results. The main analyses are
    illustrated with many examples from published papers and there is an
    extensive reference list to both the statistical and biological
    literature. The book is supported by a website that provides all
    data sets, questions for each chapter and links to software.

-   James *et al.* (2013): An Introduction to Statistical Learning
    provides an accessible overview of the field of statistical
    learning, an essential toolset for making sense of the vast and
    complex data sets that have emerged in fields ranging from biology
    to finance to marketing to astrophysics in the past twenty years.
    This book presents some of the most important modeling and
    prediction techniques, along with relevant applications. Topics
    include linear regression, classification, resampling methods,
    shrinkage approaches, tree-based methods, support vector machines,
    clustering, and more. Color graphics and real-world examples are
    used to illustrate the methods presented. Since the goal of this
    textbook is to facilitate the use of these statistical learning
    techniques by practitioners in science, industry, and other fields,
    each chapter contains a tutorial on implementing the analyses and
    methods presented in R, an extremely popular open source statistical
    software platform. Two of the authors co-wrote The Elements of
    Statistical Learning (Hastie, Tibshirani and Friedman, 2nd edition
    2009), a popular reference book for statistics and machine learning
    researchers. An Introduction to Statistical Learning covers many of
    the same topics, but at a level accessible to a much broader
    audience. This book is targeted at statisticians and
    non-statisticians alike who wish to use cutting-edge statistical
    learning techniques to analyze their data. The text assumes only a
    previous course in linear regression and no knowledge of matrix
    algebra.

-   Emden (2008): The typical biology student is “hardwired” to be wary
    of any tasks involving the application of mathematics and
    statistical analyses, but the plain fact is much of biology requires
    interpretation of experimental data through the use of statistical
    methods. This unique textbook aims to demystify statistical formulae
    for the average biology student. Written in a lively and engaging
    style, Statistics for Terrified Biologists draws on the author's 30
    years of lecturing experience. One of the foremost entomologists of
    his generation, van Emden has an extensive track record for
    successfully teaching statistical methods to even the most guarded
    of biology students. For the first time basic methods are presented
    using straightforward, jargon-free language. Students are taught to
    use simple formulae accurately to interpret what is being measured
    with each test and statistic, while at the same time learning to
    recognize overall patterns and guiding principles. Complemented by
    simple illustrations and useful case studies, this is an ideal
    statistics resource tool for undergraduate biology and environmental
    science students who lack confidence in their mathematical
    abilities.

-   Agresti (2002): The use of statistical methods for categorical data
    has increased dramatically, particularly for applications in the
    biomedical and social sciences. Responding to new developments in
    the field as well as to the needs of a new generation of
    professionals and students, this new edition of the classic
    Categorical Data Analysis offers a comprehensive introduction to the
    most important methods for categorical data analysis. Designed for
    statisticians and biostatisticians as well as scientists and
    graduate students practicing statistics, Categorical Data Analysis,
    Second Edition summarizes the latest methods for univariate and
    correlated multivariate categorical responses. Readers will find a
    unified generalized linear models approach that connects logistic
    regression and Poisson and negative binomial regression for discrete
    data with normal regression for continuous data.

-   van Belle (2008): This book contains chapters titled:

    -   Begin with a Basic Formula for Sample Size–Lehr's Equation
    -   Calculating Sample Size Using the Coefficient of Variation
    -   Ignore the Finite Population Correction in Calculating Sample
        Size for a Survey
    -   The Range of the Observations Provides Bounds for the Standard
        Deviation \* Do not Formulate a Study Solely in Terms of Effect
        Size
    -   Overlapping Confidence Intervals do not Imply Nonsignificance
    -   Sample Size Calculation for the Poisson Distribution
    -   Sample Size Calculation for Poisson Distribution with Background
        Rate
    -   Sample Size Calculation for the Binomial Distribution
    -   When Unequal Sample Sizes Matter; When They Don't \* Determining
        Sample Size when there are Different Costs Associated with the
        Two Samples
    -   Use the Rule of Threes for 95% Upper Bounds when there Have Been
        No Events
    -   Sample Size Calculations Should be Based on the Way the Data
        will be Analyzed

-   Grolemund & Wickham (2016): This is the website for {"}R for Data
    Science{"}. This book will teach you how to do data science with R:
    You'll learn how to get your data into R, get it into the most
    useful structure, transform it, visualise it and model it. In this
    book, you will find a practicum of skills for data science. Just as
    a chemist learns how to clean test tubes and stock a lab, you'll
    learn how to clean data and draw plots—and many other things
    besides. These are the skills that allow data science to happen, and
    here you will find the best practices for doing each of these things
    with R. You'll learn how to use the grammar of graphics, literate
    programming, and reproducible research to save time. You'll also
    learn how to manage cognitive resources to facilitate discoveries
    when wrangling, visualising, and exploring data.

-   Baddeley *et al.* (2015): Spatial Point Patterns: Methodology and
    Applications with R shows scientific researchers and applied
    statisticians from a wide range of fields how to analyze their
    spatial point pattern data. Making the techniques accessible to
    non-mathematicians, the authors draw on their 25 years of software
    development experiences, methodological research, and broad
    scientific collaborations to deliver a book that clearly and
    succinctly explains concepts and addresses real scientific
    questions. Practical Advice on Data Analysis and Guidance on the
    Validity and Applicability of Methods The first part of the book
    gives an introduction to R software, advice about collecting data,
    information about handling and manipulating data, and an accessible
    introduction to the basic concepts of point processes. The second
    part presents tools for exploratory data analysis, including
    non-parametric estimation of intensity, correlation, and spacing
    properties. The third part discusses model-fitting and statistical
    inference for point patterns. The final part describes point
    patterns with additional {"}structure,{"} such as complicated marks,
    space-time observations, three- and higher-dimensional spaces,
    replicated observations, and point patterns constrained to a network
    of lines. Easily Analyze Your Own Data Throughout the book, the
    authors use their spatstat package, which is free, open-source code
    written in the R language. This package provides a wide range of
    capabilities for spatial point pattern data, from basic data
    handling to advanced analytic tools. The book focuses on practical
    needs from the user's perspective, offering answers to the most
    frequently asked questions in each chapter.

-   Hobbs & Hooten (2015): Bayesian modeling has become an indispensable
    tool for ecological research because it is uniquely suited to deal
    with complexity in a statistically coherent way. This textbook
    provides a comprehensive and accessible introduction to the latest
    Bayesian methods—in language ecologists can understand. Unlike other
    books on the subject, this one emphasizes the principles behind the
    computations, giving ecologists a big-picture understanding of how
    to implement this powerful statistical approach. Bayesian Models is
    an essential primer for non-statisticians. It begins with a
    definition of probability and develops a step-by-step sequence of
    connected ideas, including basic distribution theory, network
    diagrams, hierarchical models, Markov chain Monte Carlo, and
    inference from single and multiple models. This unique book places
    less emphasis on computer coding, favoring instead a concise
    presentation of the mathematical statistics needed to understand how
    and why Bayesian analysis works. It also explains how to write out
    properly formulated hierarchical Bayesian models and use them in
    computing, research papers, and proposals. This primer enables
    ecologists to understand the statistical principles behind Bayesian
    modeling and apply them to research, teaching, policy, and
    management.

    -   Presents the mathematical and statistical foundations of
        Bayesian modeling in language accessible to non-statisticians
    -   Covers basic distribution theory, network diagrams, hierarchical
        models, Markov chain Monte Carlo, and more - Deemphasizes
        computer coding in favor of basic principles
    -   Explains how to write out properly factored statistical
        expressions representing Bayesian models

-   Zuur *et al.* (2017): In Volume I we explain how to apply linear
    regression models, generalised linear models (GLM), and generalised
    linear mixed-effects models (GLMM) to spatial, temporal, and
    spatial-temporal data. The models that will be employed use the
    Gaussian and gamma distributions for continuous data, the Poisson
    and negative binomial distributions for count data, the Bernoulli
    distribution for absence–presence data, and the binomial
    distribution for proportional data.In Volume II we apply
    zero-inflated models and generalised additive (mixed-effects) models
    to spatial and spatial-temporal data. We also discuss models with
    more exotic distributions like the generalised Poisson distribution
    to deal with underdispersion and the beta distribution to analyse
    proportional data.

-   Zuur *et al.* (2010):

    1.  While teaching statistics to ecologists, the lead authors of
        this paper have noticed common statistical problems. If a
        randomsample of theirwork (including scientific papers) produced
        before doing these courses were selected, half would probably
        contain violations of the underlying assumptions of the
        statistical techniquesemployed.
    2.  Some violations have little impact on the results or ecological
        conclusions; yet others increase type I or type II errors,
        potentially resulting in wrong ecological conclusions. Most of
        these violations can be avoided by applying better data
        exploration. These problems are especially trouble- somein
        applied ecology, wheremanagement and policy decisions are often
        at stake.
    3.  Here, we provide a protocol for data exploration; discuss
        current tools to detect outliers, heterogeneity of variance,
        collinearity, dependence of observations, problems with
        interactions, double zeros in multivariate analysis, zero
        inflation in generalized linear modelling, and the correct type
        of relationships between dependent and independent variables;
        and provide advice on how to address these problems when they
        arise. We also address misconceptions about normality, and
        provide advice on data transformations.
    4.  Data exploration avoids type I and type II errors, among other
        problems, thereby reducing the chance ofmaking wrong ecological
        conclusions and poor recommendations. It is therefore essential
        for good quality management and policy based on statistical
        analyses. Key-words:

-   Kelleher & Wagener (2011): Our ability to visualize scientific data
    has evolved significantly over the last 40 years. However, this
    advancement does not necessarily alleviate many common pitfalls in
    visualization for scientific journals, which can inhibit the ability
    of readers to effectively understand the information presented. To
    address this issue within the context of visualizing environmental
    data, we list ten guidelines for effective data visualization in
    scientific publications. These guidelines support the primary
    objective of data visualization, i.e. to effectively convey
    information. We believe that this small set of guidelines based on a
    review of key visualization literature can help researchers improve
    the communication of their results using effective visualization.
    Enhancement of environmental data visualization will further improve
    research presentation and communication within and across
    disciplines.

-   Lohr (2010): Sharon L. Lohr's SAMPLING: DESIGN AND ANALYSIS, 2ND
    EDITION, provides a modern introduction to the field of survey
    sampling intended for a wide audience of statistics students.
    Practical and authoritative, the book is listed as a standard
    reference for training on real-world survey problems by a number of
    prominent surveying organizations. Lohr concentrates on the
    statistical aspects of taking and analyzing a sample, incorporating
    a multitude of applications from a variety of disciplines. The text
    gives guidance on how to tell when a sample is valid or not, and how
    to design and analyze many different forms of sample surveys. Recent
    research on theoretical and applied aspects of sampling is included,
    as well as optional technology instructions for using statistical
    software with survey data.

-   Zuur *et al.* (2009): Building on the successful Analysing
    Ecological Data (Zuur *et al.*, 2007), the authors now provide an
    expanded introduction to using regression and its extensions in
    analysing ecological data. As with the earlier book, real data sets
    from postgraduate ecological studies or research projects are used
    throughout. The first part of the book is a largely non-mathematical
    introduction to linear mixed effects modelling, GLM and GAM, zero
    inflated models, GEE, GLMM and GAMM. The second part provides ten
    case studies that range from koalas to deep sea research. These
    chapters provide an invaluable insight into analysing complex
    ecological datasets, including comparisons of different approaches
    to the same problem. By matching ecological questions and data
    structure to a case study, these chapters provide an excellent
    starting point to analysing your own data. Data and R code from all
    chapters are available from www.highstat.com.

-   Zuur & Ieno (2016):

    1.  Scientific investigation is of value only insofar as relevant
        results are obtained and communicated, a task that requires
        organizing, evaluating, analysing and unambiguously
        communicating the significance of data. In this context, working
        with ecological data, reflecting the complexities and
        interactions of the natural world, can be a challenge. Recent
        innovations for statistical analysis ofmultifaceted interrelated
        datamake obtaining more accu- rate andmeaningful results
        possible, but key decisions of the analyses to use, and which
        components to present in a scientific paper or report, may be
        overwhelming.
    2.  We offer a 10-step protocol to streamline analysis of data
        thatwill enhance understanding of the data, the statistical
        models and the results, and optimize communication with the
        reader with respect to both the procedure and the outcomes. The
        protocol takes the investigator from study design and
        organization of data (formulating relevant questions,
        visualizing data collection, data exploration, identifying
        dependency), through conducting analysis (presenting, fitting
        and validating the model) and presenting output (numerically and
        visually), to extending themodel via simulation. Each step
        includes procedures to clarify aspects of the data that affect
        statistical analysis, as well as guidelines for written
        presentation. Steps are illustrated with examples using data
        from the literature.
    3.  Following this protocol will reduce the organization, analysis
        and presentation ofwhatmay be an overwhelming information
        avalanche into sequential and, more to the point, manageable,
        steps. It provides guidelines for selecting optimal statistical
        tools to assess data relevance and significance, for choosing
        aspects of the analysis to include in a published report and for
        clearly communicating information.

-   Gelman & Hill (2007): Data Analysis Using Regression and
    Multilevel/Hierarchical Models is a comprehensive manual for the
    applied researcher who wants to perform data analysis using linear
    and nonlinear regression and multilevel models. The book introduces
    a wide variety of models, whilst at the same time instructing the
    reader in how to fit these models using available software packages.
    The book illustrates the concepts by working through scores of real
    data examples that have arisen from the authors' own applied
    research, with programming codes provided for each one. Topics
    covered include causal inference, including regression,
    poststratification, matching, regression discontinuity, and
    instrumental variables, as well as multilevel logistic regression
    and missing-data imputation. Practical tips regarding building,
    fitting, and understanding are provided throughout.

-   Lindenmayer & Likens (2010): Long-term monitoring programs are
    fundamental to understanding the natural environment and effectively
    tackling major environmental problems. Yet they are often done very
    poorly and ineffectively. Effective Ecological Monitoring describes
    what makes successful and unsuccessful long-term monitoring
    programs. Short and to the point, it illustrates key aspects with
    case studies and examples. It is based on the collective experience
    of running long-term research and monitoring programs of the two
    authors -- experience which spans more than 70 years. The book first
    outlines why long-term monitoring is important, then discusses why
    long-term monitoring programs often fail. The authors then highlight
    what makes good and effective monitoring. These good and bad aspects
    of long-term monitoring programs are further illustrated in the
    fourth chapter of the book. The final chapter sums up the future of
    long-term monitoring programs and how to make them better, more
    effective and better targeted.

-   Bolker (2008): Ecological Models and Data in R is the first truly
    practical introduction to modern statistical methods for ecology. In
    step-by-step detail, the book teaches ecology graduate students and
    researchers everything they need to know in order to use maximum
    likelihood, information-theoretic, and Bayesian techniques to
    analyze their own data using the programming language R. Drawing on
    extensive experience teaching these techniques to graduate students
    in ecology, Benjamin Bolker shows how to choose among and construct
    statistical models for data, estimate their parameters and
    confidence limits, and interpret the results. The book also covers
    statistical frameworks, the philosophy of statistical modeling, and
    critical mathematical functions and probability distributions. It
    requires no programming background--only basic calculus and
    statistics.

    -   Practical, beginner-friendly introduction to modern statistical
        techniques for ecology using the programming language R
    -   Step-by-step instructions for fitting models to messy,
        real-world data
    -   Balanced view of different statistical approaches
    -   Wide coverage of techniques -- from simple (distribution
        fitting) to complex (state-space modeling)
    -   Techniques for data manipulation and graphical display
    -   Companion Web site with data and R code for all examples

Bibliography
------------

Agresti A. (2002). Categorical Data Analysis (Second Edition). John
Wiley & Sons, Inc.

Baddeley A., Rubak E. & Turner R. (2015). Spatial Point Patterns:
Methodology and Applications with R. Chapman; Hall/CRC, Boca Raton.

Bolker B.M. (2008). Ecological Models and Data in R. Princeton
University Press, Princeton, NJ.

Emden H. van (2008). Statistics for Terrified Biologists. Blackwell
Publishing.

Gelman A. & Hill J. (2007). Data analysis using regression and
multilevel/hierarchical models. Cambridge University Press, Cambridge.
URL: <http://www.loc.gov/catdir/enhancements/fy0668/2006040566-t.html>.

Grolemund G. & Wickham H. (2016). R for Data Science. URL:
<http://r4ds.had.co.nz/>.

Hobbs N.T. & Hooten M.B. (2015). Bayesian Models: A Statistical Primer
for Ecologists. Princeton University Press.

James G., Witten D., Hastie T. & Tibshirani R. (2013). An Introduction
to Statistical Learning with Applications in R. Springer.

Kass R.E., Caffo B.S., Davidian M., Meng X.-L., Yu B. & Reid N. (2016).
Ten Simple Rules for Effective Statistical Practice. PLOS Computational
Biology 12 (6): e1004961. URL:
<http://dx.plos.org/10.1371/journal.pcbi.1004961>. DOI:
[10.1371/journal.pcbi.1004961](https://doi.org/10.1371/journal.pcbi.1004961).

Kelleher C. & Wagener T. (2011). Ten guidelines for effective data
visualization in scientific publications. Environmental Modelling &
Software 26 (6): 822–827. URL:
<https://www.sciencedirect.com/science/article/pii/S1364815210003270>.
DOI:
[10.1016/J.ENVSOFT.2010.12.006](https://doi.org/10.1016/J.ENVSOFT.2010.12.006).

Lindenmayer D. & Likens G.E. (2010). Effective ecological monitoring.
Earthscan, London, UK.

Lohr S.L. (2010). Sampling: Design and Analysis, Second Edi. ed.
Brooks/Cole.

McElreath R. (2015). Statistical rethinking : a Bayesian course with
examples in R and Stan. Chapman; Hall/CRC, Boca Raton.

Quinn G. & Keough M. (2002). Experimental design and data analysis for
biologists. Cambridge University Press. URL: <http://www.cambridge.org>.

van Belle G. (2008). Statistical Rules of Thumb: Second Edition. John
Wiley & Sons, Inc. DOI:
[10.1002/9780470377963](https://doi.org/10.1002/9780470377963).

Zuur A.F. & Ieno E.N. (2016). A protocol for conducting and presenting
results of regression-type analyses. Methods in Ecology and Evolution 7
(6): 636–645. URL: <http://doi.wiley.com/10.1111/2041-210X.12577>. DOI:
[10.1111/2041-210X.12577](https://doi.org/10.1111/2041-210X.12577).

Zuur A.F., Ieno E.N. & Elphick C.S. (2010). A protocol for data
exploration to avoid common statistical problems. Methods in Ecology and
Evolution 1 (9999): 3–14.

Zuur A.F., Ieno E.N. & Smith G.M. (2007). Analysing ecological data.
Springer Verlag.

Zuur A.F., Ieno E.N., Anatoly, A & Saveliev (2017). Beginner’s guide to
spatial, temporal, and spatial-temporal ecological data analysis with
R-INLA. Highland Statistics Ltd. URL:
<http://www.highstat.com/Books/BGS/SpatialTemp/Zuuretal2017_TOCOnline.pdf>.

Zuur A.F., Ieno E.N., Walker N.J., Saveliev A.A. & Smith G.M. (2009).
Mixed effects models and extensions in ecology with R. Springer.
