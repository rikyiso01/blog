---
title: Overengineer your CV
published: true
description: An overengineered Curriculum Vitae
tags: architecture, learning, tooling
cover_image: https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7m8lf74czkq4t0qujp4n.png
# Use a ratio of 100:42 for best results.
# published_at: 2025-03-13 15:51 +0000
---

Hi everyone, I'm [rikyiso01](https://github.com/rikyiso01), this is my first blog post, I hope you will like it.

## Introduction

Every time I have to apply for a job or for an activity I have to submit a CV tailored for the position I am about to cover.

There are online tools for helping you manage your CV but since I am a programmer I wanted a more code focused approach.

## Inspirational reading

- [How to totally over-engineer your CV in a few easy steps](https://dev.to/jj/how-to-totally-over-engineer-your-cv-in-a-few-easy-steps-6ha):
    Uses latex for templating the CV, I wanted to support also other formats for the template like Markdown or HTML
- [How to totally over-engineer your CV, part two](https://dev.to/jj/how-to-totally-over-engineer-your-cv-part-two-1oip):
    Part 2 of the previous one, uses CSV to represent only jobs timeline, I wanted to store more general data in a document
- [Curriculum vitae as code](https://philippart-s.github.io/blog/articles/resume-as-code/):
    Uses YAML to store generic data but the templating system is locked with Jekyll,
    I wanted a more generic structure for the themes to support any template system

After reading these articles I decided to tackle this problem in my own way since none of the projects satisfied my needs.

## Ideas

A curriculum vitae is just a collection of stuff you have done. This collection can be stored inside a database.

When you tailor your curriculum for a specific job, you are just selecting a subset of elements from the database.

Then finally to the selected subset you apply a theme in order to make it pleasing for the eye.

## Requirements for the project

- Usage of open source tools
- Ability to build the CV using only the cli
- Ability to edit it using any local editor
- Ability to use git for versioning and backing up the code
- Support for different templating systems

## Architecture

So, starting from this idea and the requirements, I can create my tool by composing 3 different components:

1. A database
2. A filter
3. A theme

![Flowchart of the previously described architecture](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/gw22hxqhycn2wail54ip.png)

## Implementation

### Database

For implementing the database I have decided to use a YAML file since it is possible to edit it using a text editor.
For structuring the YAML file, I have decided to use as a base the [json-resume](https://jsonresume.org/) JSON-Schema.
Since the schema is a little limited I have added some more fields and renamed some to satisfy my needs.

Extract from my YAML database:
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

### Filter

Then the content of the YAML is passed to a program called [yq](https://github.com/mikefarah/yq) which takes a [jq-filter](https://jqlang.org/) as an input and returns a json with the filter applied to it as an output.

Example of a jq-filter for selecting a subset of elements in the database:
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

### Theme

For implementing the themes I have decided to use [nix](https://nixos.org/) [flakes](https://wiki.nixos.org/wiki/Flakes) since they allow each theme to specify their own dependencies and which command to run with the resulting JSON from the previous step as input.
Another alternative could have been to use [docker](https://www.docker.com/), but I wanted to learn more about nix.

### Pipeline

A bash command for running the pipeline can be:
```bash
yq -f "$filter" "$data" | nix run "$theme"
```
resulting in the following architecture:

![Flowchart of the pipeline](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/muc7xs4vvmqqp07fciwu.png)

## Theme example

Since I like standards, I have decided to use as my first theme example, an [Europass](https://europass.europa.eu/en) like theme (I know, a lot of people hate this format).


For structuring this theme I have decided to use the following architecture:

1. The JSON input is passed to [jinja2-cli](https://github.com/mattrobenolt/jinja2-cli)
    which applies it to a Markdown [jinja template](https://jinja.palletsprojects.com/en/stable/templates/)
2. The resulting Markdown is passed to [pandoc](https://pandoc.org/) to convert it to HTML
3. To the resulting HTML is applied a custom CSS which tries to mimic the Europass theme,
    and it is converted to a PDF using [pagedjs-cli](https://www.npmjs.com/package/pagedjs-cli)

![Flowchart of the theme architecture](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/62lqpmwhjyiubxmgukbw.png)

Bash command which is run by the nix flake:
```bash
jinja2 ./templates/template.md data.yml --outfile result.md
pandoc --defaults ./pandoc.yml result.md --output result.html
pagedjs-cli result.html --output result.pdf
```

## Rendering example

An example of the PDF rendering using the Europass theme can be found
[here](https://github.com/rikyiso01/cv/releases/download/internship/cv.pdf).

Pictures of part of the PDF:
![Example of a rendering using the Europass theme](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ozraziij0h88qnp3mgha.png)
![Another example of a rendering using the Europass theme](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rnn2zsvz8f9pgreip297.png)

## Language support

Since I am currently in Italy, sometimes I need my curriculum to be translated into Italian, an extension of the architecture to support multiple languages can be to add a language entry into the YAML database and then use that entry in the theme to change the language of the applied theme.

## Code

The code for the tool and my CVs created with it can be found on my [GitHub repo](https://github.com/rikyiso01/cv).

## Possible development

- Use pandoc for both templating and conversion in the Europass theme
- Add live reloading to simplify the writing process

## Conclusion

This architecture was very funny to design and implement, maybe it is a little overkill, but I like it.
I will in the immediate future use it and see if it will be able to scale to all the possible occasions I will need a CV.

Thanks for reading.
