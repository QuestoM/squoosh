/**
 * Copyright 2020 Google Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { h, FunctionalComponent } from 'preact';

import baseCss from 'css:./base.css';
import initialCss from 'initial-css:';
import { allSrc } from 'client-bundle:client/initial-app';
import favicon from 'url:static-build/assets/favicon.ico';
import ogImage from 'url:static-build/assets/icon-large-maskable.png';
import { escapeStyleScriptContent, siteOrigin } from 'static-build/utils';
import Intro from 'shared/prerendered-app/Intro';
import snackbarCss from 'css:../../../shared/custom-els/snack-bar/styles.css';
import * as snackbarStyle from '../../../shared/custom-els/snack-bar/styles.css';

interface Props {}

const Index: FunctionalComponent<Props> = () => (
  <html lang="en">
    <head>
      <title>Squoosh</title>
      <meta
        name="description"
        content="Squoosh - Free online image optimizer and compressor with superior compression algorithms. Reduce image file sizes while maintaining quality. Supports JPG, PNG, WebP, AVIF and more."
      />
      <meta
        name="keywords"
        content="image compression, image optimizer, image compressor, photo compression, webp converter, avif converter, image optimization tool, reduce image size, compress images online, free image compressor"
      />
      <meta name="author" content="Google Chrome Labs" />
      <meta name="robots" content="index, follow" />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:site" content="@SquooshApp" />
      <meta name="twitter:creator" content="@ChromiumDev" />
      <meta
        name="twitter:title"
        content="Squoosh - Free Online Image Optimizer"
      />
      <meta
        name="twitter:description"
        content="Compress and optimize your images with Squoosh. Free, fast, and works entirely in your browser. Reduce file size while maintaining quality."
      />
      <meta name="twitter:image" content={`${siteOrigin}${ogImage}`} />
      <meta
        property="og:title"
        content="Squoosh - Free Online Image Optimizer"
      />
      <meta property="og:type" content="website" />
      <meta property="og:url" content={siteOrigin} />
      <meta property="og:image" content={`${siteOrigin}${ogImage}`} />
      <meta
        property="og:image:secure_url"
        content={`${siteOrigin}${ogImage}`}
      />
      <meta property="og:image:type" content="image/png" />
      <meta property="og:image:width" content="500" />
      <meta property="og:image:height" content="500" />
      <meta
        property="og:image:alt"
        content="A cartoon of a hand squeezing an image file on a dark background."
      />
      <meta
        property="og:description"
        content="Compress and optimize your images with Squoosh. Free, fast, and works entirely in your browser. Reduce file size while maintaining quality."
      />
      <meta property="og:site_name" content="Squoosh" />
      <script type="application/ld+json">
        {JSON.stringify(
          {
            '@context': 'https://schema.org',
            '@type': 'WebApplication',
            name: 'Squoosh',
            url: siteOrigin,
            description:
              'Free online image optimizer and compressor with superior compression algorithms. Reduce image file sizes while maintaining quality.',
            applicationCategory: 'Image Processing',
            operatingSystem: 'Any',
            offers: {
              '@type': 'Offer',
              price: '0',
              priceCurrency: 'USD',
            },
            creator: {
              '@type': 'Organization',
              name: 'Google Chrome Labs',
            },
          },
          null,
          2,
        )}
      </script>
      <meta
        name="viewport"
        content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"
      />
      <meta name="mobile-web-app-capable" content="yes" />
      <meta name="apple-mobile-web-app-capable" content="yes" />
      <link rel="shortcut icon" href={favicon} />
      <link rel="apple-touch-icon" href={ogImage} />
      <meta name="theme-color" content="#ff3385" />
      <link rel="manifest" href="/manifest.json" />
      <link rel="canonical" href={siteOrigin} />
      <style
        dangerouslySetInnerHTML={{ __html: escapeStyleScriptContent(baseCss) }}
      />
      <style
        dangerouslySetInnerHTML={{
          __html: escapeStyleScriptContent(initialCss),
        }}
      />
    </head>
    <body>
      <div id="app">
        <Intro />
        <noscript>
          <style
            dangerouslySetInnerHTML={{
              __html: escapeStyleScriptContent(snackbarCss),
            }}
          />
          <snack-bar>
            <div
              class={snackbarStyle.snackbar}
              aria-live="assertive"
              aria-atomic="true"
              aria-hidden="false"
            >
              <div class={snackbarStyle.text}>
                Initialization error: This site requires JavaScript, which is
                disabled in your browser.
              </div>
              <a class={snackbarStyle.button} href="/">
                reload
              </a>
            </div>
          </snack-bar>
        </noscript>
      </div>
      <script
        dangerouslySetInnerHTML={{
          __html: escapeStyleScriptContent(allSrc),
        }}
      />
    </body>
  </html>
);

export default Index;
