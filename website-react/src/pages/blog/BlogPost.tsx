import { Suspense } from 'react'
import { useParams, Link } from 'react-router-dom'
import { Seo } from '../../components/Seo'
import { BreadcrumbSchema } from '../../components/BreadcrumbSchema'
import { BlogPostingSchema } from '../../components/BlogPostingSchema'
import { POSTS } from '../../content/posts'
import { NotFound } from '../NotFound'
import './Blog.css'

export function BlogPost() {
  const { slug } = useParams()
  const post = POSTS.find((p) => p.slug === slug)

  // Was a client-side <Navigate to="/blog"> - that sent crawlers to a
  // *different* indexable page instead of ever showing a 404 for this one.
  // Rendering NotFound directly at least puts <meta robots noindex> into
  // the rendered page for this URL. The raw HTTP response is still a 200
  // with no noindex in it at all (this is a client-rendered SPA, nothing
  // is prerendered) - a crawler that doesn't execute JS still sees a plain
  // 200. A real 404 status/head here needs prerendering or a hosting-level
  // rewrite rule, not just this component.
  if (!post) return <NotFound />

  const { Component } = post

  return (
    <>
      <Seo
        title={`${post.seoTitle} | Collabsy`}
        description={post.description}
        path={`/blog/${post.slug}`}
        type="article"
      />
      <BreadcrumbSchema
        items={[
          { name: 'Home', path: '/' },
          { name: 'Blog', path: '/blog' },
          { name: post.title, path: `/blog/${post.slug}` },
        ]}
      />
      <BlogPostingSchema
        title={post.title}
        description={post.description}
        path={`/blog/${post.slug}`}
        publishedDate={post.publishedDate}
      />

      <section className="page-hero">
        <div className="container">
          <Link to="/blog" className="blog-back-link">
            ← Back to Blog
          </Link>
          <span className={`blog-audience-tag blog-audience-${post.audience.toLowerCase()}`}>{post.audience}</span>
          <h1 className="page-hero-title display-heading">{post.title}</h1>
          <p className="blog-meta-line">
            {post.readingTime} ·{' '}
            {new Date(post.publishedDate).toLocaleDateString('en-IN', {
              year: 'numeric',
              month: 'long',
              day: 'numeric',
            })}
          </p>
        </div>
      </section>

      <section className="section">
        <div className="container blog-post-container">
          <Suspense fallback={<div style={{ minHeight: '40vh' }} />}>
            <Component />
          </Suspense>
        </div>
      </section>
    </>
  )
}
