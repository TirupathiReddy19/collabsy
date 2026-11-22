import { Suspense } from 'react'
import { useParams, Navigate, Link } from 'react-router-dom'
import { Seo } from '../../components/Seo'
import { BreadcrumbSchema } from '../../components/BreadcrumbSchema'
import { POSTS } from '../../content/posts'
import './Blog.css'

export function BlogPost() {
  const { slug } = useParams()
  const post = POSTS.find((p) => p.slug === slug)

  if (!post) return <Navigate to="/blog" replace />

  const { Component } = post

  return (
    <>
      <Seo title={`${post.seoTitle} | Collabsy`} description={post.description} path={`/blog/${post.slug}`} />
      <BreadcrumbSchema
        items={[
          { name: 'Home', path: '/' },
          { name: 'Blog', path: '/blog' },
          { name: post.title, path: `/blog/${post.slug}` },
        ]}
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
