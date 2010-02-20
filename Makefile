JRUBY_HOME=../jruby-1.4.0/
JRUBY_ORIG_HOME=../jruby-1.4.0-orig/
ANTLR_JAR=build_lib/antlr-3.2.jar

BUILD_CLASSPATH=.:lib/jruby.jar:lib/antlr-runtime-3.2.jar
CLASSPATH=$(BUILD_CLASSPATH):lib/rsense.jar

.PHONY: all rsense doc

all: rsense

rsense: antlr
	mkdir -p build
	javac -cp $(BUILD_CLASSPATH) \
		-d build \
		-Xlint:all \
		src/org/cx4a/rsense/*.java \
		src/org/cx4a/rsense/typing/*.java \
		src/org/cx4a/rsense/typing/annotation/*.java \
		src/org/cx4a/rsense/typing/runtime/*.java \
		src/org/cx4a/rsense/typing/vertex/*.java \
		src/org/cx4a/rsense/ruby/*.java \
		src/org/cx4a/rsense/parser/*.java \
		src/org/cx4a/rsense/util/*.java
	jar cf lib/rsense.jar -C build org

run-script:
	java -cp $(CLASSPATH) org.cx4a.rsense.Main script $(SCRIPT) $(OPTIONS)

run-code-completion:
	java -cp $(CLASSPATH) org.cx4a.rsense.Main code-completion --file=$(FILE) --encoding=UTF-8 --location=$(LOCATION) $(OPTIONS)

run-type-inference:
	java -cp $(CLASSPATH) org.cx4a.rsense.Main type-inference --file=$(FILE) --encoding=UTF-8 --location=$(LOCATION) $(OPTIONS)

run-type-inference-prof:
	java -agentlib:hprof=cpu=samples,depth=10 -cp $(CLASSPATH) org.cx4a.rsense.Main type-inference --file=$(FILE) --encoding=UTF-8 --location=$(LOCATION) $(OPTIONS)

run-help:
	java -cp $(CLASSPATH) org.cx4a.rsense.Main help

run-version:
	java -cp $(CLASSPATH) org.cx4a.rsense.Main version

run-test:
	java -cp $(CLASSPATH) org.cx4a.rsense.Main script test/script/all.rsense --test-color

antlr:
	java -cp .:$(ANTLR_JAR) org.antlr.Tool -make \
		src/org/cx4a/rsense/parser/*.g

jruby-diff:
	diff -ruN \
		-x ri \
		-x DefaultRubyParser.java \
		-x YyTables.java \
		$(JRUBY_ORIG_HOME) $(JRUBY_HOME) \
		> etc/jruby-1.4.0.patch

doc:
	ruby etc/txt2html.rb doc/*.txt

clean:
	rm -rf build
	rm -f hs_err_pid*.log \
        java.hprof.txt \
		doc/*.html \
		lib/rsense.jar \
		TypeAnnotation.tokens \
		src/org/cx4a/rsense/*.class \
		src/org/cx4a/rsense/typing/*.class \
		src/org/cx4a/rsense/typing/annotation/*.class \
		src/org/cx4a/rsense/typing/runtime/*.class \
		src/org/cx4a/rsense/typing/vertex/*.class \
		src/org/cx4a/rsense/ruby/*.class \
		src/org/cx4a/rsense/parser/*.class \
		src/org/cx4a/rsense/parser/TypeAnnotation*.java \
		src/org/cx4a/rsense/util/*.class
