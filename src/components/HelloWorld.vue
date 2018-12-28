<template>
  <div id="editor">
    <textarea :value="input" @input="update"></textarea>
    <div v-html="compiledMarkdown"></div>
  </div>
</template>

<script lang="ts">
import {Component, Prop, Vue, Watch} from "vue-property-decorator";
import { TextlintKernel } from '@textlint/kernel';
import _ from 'lodash';
import marked from 'marked';

@Component
export default class HelloWorld extends Vue {
  @Prop() private msg!: string;

  input: string = '# hello Vue.js';

  debounce = _.debounce;

  get compiledMarkdown() {
      return marked(this.input, {sanitize: true});
  }

    update(e) {
        console.log('debounce');
        this.input = e.target.value;
    }

    mounted() {
        this.update = _.debounce(this.update, 300);

      const kernel = new TextlintKernel();

      const options = {
          ext: '.md',
          plugins: [
              {
                  pluginId: 'markdown',
                  plugin: require('@textlint/textlint-plugin-markdown'),
              },
          ],
          // rules: require('textlint-rule-preset-ja-spacing/src'),
          rules: [
              {
                  ruleId: 'no-mix-dearu-desumasu',
          //         // rule: require('textlint-rule-no-mix-dearu-desumasu'),
          //         // rule: require('textlint-rule-no-todo'),
          //         rule: require('textlint-rule-preset-ja-spacing/src'),
                  rule: require('textlint-rule-ja-nakaguro-or-halfwidth-space-between-katakana'),

              },
          ],
      };

      // console.log(options);

      kernel.lintText('パソコン　ソフトはすごい。', options).then(result => {
          console.log(result);
      });
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
html, body, #editor {
  margin: 0;
  height: 100%;
  font-family: 'Helvetica Neue', Arial, sans-serif;
  color: #333;
}

textarea, #editor div {
  display: inline-block;
  width: 49%;
  height: 100%;
  vertical-align: top;
  box-sizing: border-box;
  padding: 0 20px;
}

textarea {
  border: none;
  border-right: 1px solid #ccc;
  resize: none;
  outline: none;
  background-color: #f6f6f6;
  font-size: 14px;
  font-family: 'Monaco', courier, monospace;
  padding: 20px;
}

code {
  color: #f66;
}
</style>
