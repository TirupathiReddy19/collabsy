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

  // Was a client-side <Navigate to="/blog"> - that still serves a 200 to
  // crawlers (a soft-404), since the redirect only happens after React
  // hydrates. Rendering NotFound directly gets its <meta robots noindex>
  // into the actual response for an unknown slug instead.
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
