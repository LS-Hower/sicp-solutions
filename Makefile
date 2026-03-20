SRC = src
DST = docs

SCRIBBLE = scribble
FLAGS = --dest $(DST)

SCRIBS = $(wildcard $(SRC)/*.scrbl)
HTMLS = $(patsubst $(SRC)/%.scrbl,$(DST)/%.html,$(SCRIBS))

all: $(HTMLS)

$(DST)/%.html: $(SRC)/%.scrbl
	$(SCRIBBLE) $(FLAGS) $<
