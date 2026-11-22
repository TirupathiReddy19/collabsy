import { Link } from 'react-router-dom'
import { Seo } from '../../components/Seo'
import { BreadcrumbSchema } from '../../components/BreadcrumbSchema'
import { POSTS } from '../../content/posts'
import './Blog.css'

export function BlogIndex() {
  return (
    <>
      <Seo
        title="Blog | Collabsy"
        description="Practical guides for Creators and Brands on influencer marketing — from landing your first brand deal to running a campaign that actually converts."
        path="/blog"
      />
      <BreadcrumbSchema items={[{ name: 'Home', path: '/' }, { name: 'Blog', path: '/blog' }]} />

      <section className="page-hero">
        <div className="container">
          <h1 className="page-hero-title display-heading">Collabsy Blog</h1>
          <p className="page-hero-sub">Practical guides for Creators and Brands — no fluff, no vanity metrics.</p>
        </div>
      </section>

      <section className="section">
        <div className="container">
          <div className="blog-grid">
            {POSTS.map((post) => (
              <Link key={post.slug} to={`/blog/${post.slug}`} className="blog-card">
                <span className={`blog-audience-tag blog-audience-${post.audience.toLowerCase()}`}>
                  {post.audience}
                </span>
                <h2 className="blog-card-title">{post.title}</h2>
                <p className="blog-card-excerpt">{post.description}</p>
                <span className="blog-card-meta">{post.readingTime}</span>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </>
  )
}
