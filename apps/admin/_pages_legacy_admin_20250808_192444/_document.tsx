import Document, { Html, Head, Main, NextScript, DocumentContext } from "next/document";
import { createCache, extractStyle, StyleProvider } from "@ant-design/cssinjs";

export default class MyDocument extends Document {
  static async getInitialProps(ctx: DocumentContext) {
    const cache = createCache();
    const originalRenderPage = ctx.renderPage;
    let css = "";

    ctx.renderPage = () =>
      originalRenderPage({
        enhanceApp: (App: any) => (props) => {
          const res = (
            <StyleProvider cache={cache}>
              <App {...props} />
            </StyleProvider>
          );
          css = extractStyle(cache, true);
          return res;
        }
      });

    const initialProps = await Document.getInitialProps(ctx);
    return {
      ...initialProps,
      styles: (
        <>
          {initialProps.styles}
          <style id="antd-cssinjs" dangerouslySetInnerHTML={{ __html: css }} />
        </>
      )
    };
  }

  render() {
    return (
      <Html lang="tr">
        <Head />
        <body>
          <Main />
          <NextScript />
        </body>
      </Html>
    );
  }
}
