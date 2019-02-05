<template>
  <div id="editor">
    <textarea class="raw-input" :value="input" @input="update"></textarea>
    <div class="editor-result">
      <div class="select">
        <input type="radio" id="markdown" value="markdown" v-model="picked">
        <label for="markdown">Markdown</label>
        <input type="radio" id="textlint" value="textlint" v-model="picked">
        <label for="textlint">textlint {{ errorMessageLength }}</label>
      </div>
      <div v-if="picked === 'markdown'" class="marked-input" v-html="compiledMarkdown"></div>
      <div v-else class="status">
        <ul>
          <li v-for="error in errorMessages">
            <span> ({{ error.line }}, {{ error.column }})</span>
            {{ error.message }}
            <span> {{error.ruleId}}</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue, Watch } from 'vue-property-decorator';
import { TextlintKernel, TextlintMessage } from '@textlint/kernel';
import _ from 'lodash';
import marked from 'marked';
import ruleNakaguroOrHalfwidthSpaceBetweenKatakana from 'textlint-rule-ja-nakaguro-or-halfwidth-space-between-katakana';
import ruleNoSpaceAroundParentheses from 'textlint-rule-ja-no-space-around-parentheses';
import ruleNoTodo from 'textlint-rule-no-todo';

@Component
export default class HelloWorld extends Vue {
  input: string = '# hello Vue.js\n' + '「 カタカナ　ヒラガナ」';
  errorMessages: TextlintMessage[] = [];
  picked: 'markdown' | 'textlint' = 'markdown';

  debounce = _.debounce;

  kernel = new TextlintKernel();
  options = {
    ext: '.md',
    plugins: [
      {
        pluginId: 'markdown',
        plugin: require('@textlint/textlint-plugin-markdown'),
      },
    ],
    rules: [
      {
        ruleId: 'nakaguro-or-halfwidth-space-between-katakana',
        rule: ruleNakaguroOrHalfwidthSpaceBetweenKatakana,
      },
      {
        ruleId: 'no-space-around-parentheses',
        rule: ruleNoSpaceAroundParentheses,
      },
      {
        ruleId: 'no-todo',
        rule: ruleNoTodo,
      },
    ],
  };

  get compiledMarkdown() {
    return marked(this.input, { sanitize: true });
  }

  get errorMessageLength() {
    return this.errorMessages.length;
  }

  update(e: Event) {
    console.log('debounce');
    this.input = (<HTMLInputElement>e.target).value;
    this.doTextlint();
  }

  doTextlint() {
    console.log('doTextlint');
    this.kernel.lintText(this.input, this.options).then(result => {
      this.errorMessages = result.messages;
      console.log(result);
    });
  }

  mounted() {
    this.update = _.debounce(this.update, 300);
    this.doTextlint();
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#editor {
  display: flex;
  width: 98vw;
  height: 98vh;
}
.raw-input, .editor-result {
  width: 99%;
  height: 100%;

  text-align: left;
  padding: 10px;
  box-sizing: border-box;
}
.status {
  text-align: left;
  padding: 10px;
  box-sizing: border-box;
  width: auto;
  height: 100%;
}
.raw-input {
  border: none;
  border-right: 1px solid #ccc;
  resize: none;
  outline: none;
  background-color: #f6f6f6;
  font-size: 14px;
  padding: 20px;
}
.status {
  border: 1px solid #ccc;
}
.select {
  display: flex;
}
code {
  color: #f66;
}
</style>
