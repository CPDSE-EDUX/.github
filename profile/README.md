<h1 align="center">
  <br>
  <img src="https://raw.githubusercontent.com/CPDSE/.github/21dc420e13c7720383d8d06ed30c823e1e9a14b6/profile/assets/logo_snake_green.png" alt="CPDSE Logo" width="300">
  <br>
  <img src="https://img.shields.io/badge/Educational%20Materials-white?style=flat-square&logo=google-scholar" alt="Educational Materials">
  <br>
  CPDSE – Center for Pharmaceutical Data Science Education
  <br>
</h1>

<h4 align="center">
  Pharma is full of data, but not of data science.<br>
  We are here to change that.
</h4>

<p align="center">
  <a href="https://www.cpdse.dk/">
    <img src="https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white" alt="Website">
  </a>
  <a href="https://www.linkedin.com/company/centre-for-pharmaceutical-data-science-education/">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
  <a href="https://www.instagram.com/peopledatadrugs/">
    <img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram">
  </a>
</p>

## Educational Material

This GitHub organization hosts teaching resources that support pharmaceutical data science education and collaboration on all stages of the educational ladder. This includes materials for the pharma curriculum, PhD courses, workshops, and other resources. Organizational and research repositories can be found at [https://github.com/CPDSE](https://github.com/CPDSE). 

## Table of Contents
| Bachelor | Master | PhD | Life-long learner |
|---------|-------------|--------|-------|
| [SDU FA516: Chemical and Pharmaceutical Data Science](https://github.com/CPDSE-EDUX/SDU-BSc-FA516-Chemical-and-Pharmaceutical-Data-Science) |  |  | [R docs for beginners](https://cpdse-edux.github.io/R_documentation/) |
|  |  |  | [CheatSheets](https://github.com/CPDSE-EDUX/CheatSheets) |
|  |  |  |  [CPDSE Workshop 3D Molecular Visualisation with Blender](https://github.com/CPDSE-EDUX/CPDSE-Workshop-3D-Molecular-Visualisation-with-Blender)|
|  |  |  |  |

---

## Conventions
Each repository is one course, structured according to the following conventions.

### Naming Conventions

The convention for naming a repository is
`University`-`Education Level`-`Course Code (if applicable)`-`Course Name (English)`

| Component | Notes |
|---|---|
| University | e.g. `SDU`, `UCPH`. Use `CPDSE` instead if the material is not tied to a specific university. |
| Education Level | e.g. `BSc`, `MSc`, `PhD`. Use `Workshop` instead if the material is not tied to a specific education level. |
| Course Code | Optional — include only if the course has one (e.g. `FA100`). |
| Course Name | In English, hyphenated (spaces become `-`). |

Examples:
```
SDU-BSc-FA100-Pharmacy-Course-Name
UCPH-MSc-FA200-Another-Pharma-Course-Name
SDU-PhD-Some-PhD-Course-Name
CPDSE-PhD-Name-of-PhD-Course
CPDSE-Workshop-Name-of-your-Workshop
```
If something is not university-specific, use `CPDSE` instead of the
university. If it is not tied to a specific education level, use `Workshop`
instead of the education level. There might be exceptions to these rules. 

### Branching

The default branch (`main` or `master`) always holds the **current** year's material. 
At the end of a course run, that state is snapshotted into a branch named after the year (e.g. `2025`) and pushed to the remote. 
The default branch then continues forward for the next year.

### For Teachers
Creating a new course repository as a teacher? Use this repository as template: [https://github.com/CPDSE-EDUX/cpdse-course-template](https://github.com/CPDSE-EDUX/cpdse-course-template). Remember to name your repository according to the naming conventions.

Use the standardized branch workflow for course repos based on [this shell script file](https://github.com/CPDSE-EDUX/.github/blob/main/course%20reposities/course-manager.sh). To use the shell script, you have to do only the 3 steps shown below. If you are not used to work with Git, download the file [SKILL.md](https://github.com/CPDSE-EDUX/.github/blob/main/course%20reposities/SKILL.md) and hand it to an AI agent of your choice to get assistance. 

#### Setup (once per computer)
To use it, open Git Bash and clone the repository containing the shell script:
```bash
git clone https://github.com/CPDSE-EDUX/.github.git ~/Documents/course-tools
```

Set a global Git alias that lets you create a shortcut for a Git command that works across all repositories on your system:
```bash
git config --global alias.course-manager '!'"bash "'"$HOME/Documents/course-tools/course reposities/course-manager.sh"'
```

#### Usage
Navigate to a course repository folder. Inside, use
```bash
git course-manager
```
to run the standardized workflow to generate a new branch at the end of a semester. The script also helps you to switch between branches and other Git features. 


---

## About

CPDSE is a joint initiative between the **University of Copenhagen** and the **University of Southern Denmark**.  
We integrate modern data science into pharmaceutical education and research and educate the next generation of  
“data and drug bilinguals”.

If you’re interested in our work, feel free to explore our repositories and connect!
