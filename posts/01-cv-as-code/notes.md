# CV as code

Hi everyone, this is my first blog post, I hope you will like it

## Introduction

Every time I have to apply for a job or for an activity I have to submit a CV tailored
for the position I am about to cover.

There are online tools for helping you manage your CV but since I am a programmer I want
a more code focused approach.

### Requirements

- No proprietary format
- Usage of open source tools
- Ability to build the cv using only the cli
- Ability to use git for 

### Inspiration

[](https://dev.to/jj/how-to-totally-over-engineer-your-cv-part-two-1oip)
[](https://devpress.csdn.net/cloudnative/62f2ee28c6770329307f73eb.html)
[](https://dev.to/jj/how-to-totally-over-engineer-your-cv-in-a-few-easy-steps-6ha)

After reading these articles I decided to tackle this problem in my own way

### Ideas

A curriculum vitae is just a collection of stuff you have done
This collection can be stored inside a database

When you tailor your curriculum for a specific job, you are just selecting a subset of
elements from the database

Then finally to the selected subset you apply a theme in order to make it pleasing for
the eye

### Architecture

So, starting from this idea, I can create my tool from composing 3 different components:
1. A database
2. A filter
3. A theme

### Implementation

For implementing the database I have decided to use a YAML file since it is possible to
edit it using a text editor.
For structuring the yaml file, I have decided to use as a base the json-resume scheme and
then modify it to satisfy my needs

extract from my yaml database:
```yml
yaml-language-server: $schema=https://raw.githubusercontent.com/jsonresume/resume-schema/master/schema.json
language: en
basics:
  label: "Computer scientist"
  nationality: Italian #nonstandard
education:
  - title: "Diploma superiore"
volunteer:
  - title: "Cyberchallenge.it teacher"
work:
  - name: "Consorzio Ruvaris"
```

Then the content of the YAML is passed to a program called yq which takes a filter as an
input and returns a json with the filter applied to it as an output

example:
```jq
.education |= [.[]|select(
    .studyType=="bachelors"
    or .studyType=="master"
    or .institution=="ZenHack"
    or .title=="Silicon Valley Study Tour"
    or .title=="International Collegiate Programming Contest"
    or .title=="Leonardo Unige Scholarship Program 2022/2023"
)] | .work |= [.[]|select(
    .name=="Consorzio Ruvaris"
    or .position=="Researcher"
)] | .volunteer |= [.[]|select(
    .title=="Cyberchallenge.it teacher"
    or .title=="FLL Coach"
)]
```

For implementing the themes I have decided to use nix flakes since they allow each theme
to specify their dependency and how to apply the resulting json from the previous step to
it


A bash command for running the pipeline can be:
```bash
yq -f "$filter" "$data" | nix run "$theme"
```

### Theme example

Since I like standards, I have decided to use as my first theme example, an Europass like
theme (I know, a lot of people hate this format).

For structuring this theme I have decided to use the following architecture


1. The json input is passed to jinja2-cli which applies it to a markdown jinja template
2. The resulting markdown is passed to pandoc to convert it to html
3. To the resulting HTML is applied a custom css which tries to mimic the Europass theme,
    and it is converted to a PDF using pagedjs-cli

bash command which is run by the nix flake:
```bash
jinja2 ./templates/template.md data.yml --outfile result.md
pandoc --defaults ./pandoc.yml result.md --output result.html
pagedjs-cli result.html --output result.pdf
```

#### Example picture

## Extensions

### Language support

Since I am currently in Italy, sometimes I need my curriculum to be translated into Italian,
an extension of the architecture to support multiple languages can be to add a language
entry into the yaml database and then use that entry in the theme to change the language
of the applied theme

## Code

The code for the tool can be found on my [GitHub repo](https://github.com/rikyiso01/cv)

## Conclusion

This architecture was very funny to design and implement, I will in the immediate future
use it and see if it will be able to scale to all the possible occasion I will need a CV.
Thanks for reading
