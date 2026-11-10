import { useEffect } from "react";
import { Link } from "react-router-dom";
import { ArrowRight, Sparkles, ShoppingBag } from "lucide-react";
import CategoryItem from "../components/CategoryItem";
import HeroVideoBanner from "../components/HeroVideoBanner";
import { useProductStore } from "../stores/useProductStore";
import FeaturedProducts from "../components/FeaturedProducts";

// Curated 7 Categories with 7 high-definition images each
const categories = [
	{ 
		href: "/jeans", 
		name: "Jeans", 
		imageUrl: "/images/categories/jeans/jeans-1.jpg",
		images: [
			"/images/categories/jeans/jeans-1.jpg",
			"/images/categories/jeans/jeans-2.jpg",
			"/images/categories/jeans/jeans-3.jpg",
			"/images/categories/jeans/jeans-4.jpg",
			"/images/categories/jeans/jeans-5.jpg",
			"/images/categories/jeans/jeans-6.jpg",
			"/images/categories/jeans/jeans-7.jpg",
		]
	},
	{ 
		href: "/t-shirts", 
		name: "T-Shirts", 
		imageUrl: "/images/categories/t-shirts/t-shirts-1.jpg",
		images: [
			"/images/categories/t-shirts/t-shirts-1.jpg",
			"/images/categories/t-shirts/t-shirts-2.jpg",
			"/images/categories/t-shirts/t-shirts-3.jpg",
			"/images/categories/t-shirts/t-shirts-4.jpg",
			"/images/categories/t-shirts/t-shirts-5.jpg",
			"/images/categories/t-shirts/t-shirts-6.jpg",
			"/images/categories/t-shirts/t-shirts-7.jpg",
		]
	},
	{ 
		href: "/shoes", 
		name: "Shoes", 
		imageUrl: "/images/categories/shoes/shoes-1.jpg",
		images: [
			"/images/categories/shoes/shoes-1.jpg",
			"/images/categories/shoes/shoes-2.jpg",
			"/images/categories/shoes/shoes-3.jpg",
			"/images/categories/shoes/shoes-4.jpg",
			"/images/categories/shoes/shoes-5.jpg",
			"/images/categories/shoes/shoes-6.jpg",
			"/images/categories/shoes/shoes-7.jpg",
		]
	},
	{ 
		href: "/glasses", 
		name: "Glasses", 
		imageUrl: "/images/categories/glasses/glasses-1.jpg",
		images: [
			"/images/categories/glasses/glasses-1.jpg",
			"/images/categories/glasses/glasses-2.jpg",
			"/images/categories/glasses/glasses-3.jpg",
			"/images/categories/glasses/glasses-4.jpg",
			"/images/categories/glasses/glasses-5.jpg",
			"/images/categories/glasses/glasses-6.jpg",
			"/images/categories/glasses/glasses-7.jpg",
		]
	},
	{ 
		href: "/jackets", 
		name: "Jackets", 
		imageUrl: "/images/categories/jackets/jackets-1.jpg",
		images: [
			"/images/categories/jackets/jackets-1.jpg",
			"/images/categories/jackets/jackets-2.jpg",
			"/images/categories/jackets/jackets-3.jpg",
			"/images/categories/jackets/jackets-4.jpg",
			"/images/categories/jackets/jackets-5.jpg",
			"/images/categories/jackets/jackets-6.jpg",
			"/images/categories/jackets/jackets-7.jpg",
		]
	},
	{ 
		href: "/suits", 
		name: "Suits", 
		imageUrl: "/images/categories/suits/suits-1.jpg",
		images: [
			"/images/categories/suits/suits-1.jpg",
			"/images/categories/suits/suits-2.jpg",
			"/images/categories/suits/suits-3.jpg",
			"/images/categories/suits/suits-4.jpg",
			"/images/categories/suits/suits-5.jpg",
			"/images/categories/suits/suits-6.jpg",
			"/images/categories/suits/suits-7.jpg",
		]
	},
	{ 
		href: "/bags", 
		name: "Bags", 
		imageUrl: "/images/categories/bags/bags-1.jpg",
		images: [
			"/images/categories/bags/bags-1.jpg",
			"/images/categories/bags/bags-2.jpg",
			"/images/categories/bags/bags-3.jpg",
			"/images/categories/bags/bags-4.jpg",
			"/images/categories/bags/bags-5.jpg",
			"/images/categories/bags/bags-6.jpg",
			"/images/categories/bags/bags-7.jpg",
		]
	},
];

const HomePage = () => {
	const { fetchFeaturedProducts, products, loading } = useProductStore();

	useEffect(() => {
		fetchFeaturedProducts();
	}, [fetchFeaturedProducts]);

	const scrollToCategories = () => {
		const elem = document.getElementById("categories-section");
		if (elem) {
			elem.scrollIntoView({ behavior: "smooth" });
		}
	};

	return (
		<div className='min-h-screen text-slate-900 pb-16'>
			
			<div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-2 sm:pt-4'>
				{/* CINEMATIC VIDEO HERO BANNER (Desktop & Mobile) */}
				<HeroVideoBanner onExploreClick={scrollToCategories} />
			</div>

			{/* CATEGORIES SECTION */}
			<section id='categories-section' className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16'>
				<div className='flex flex-col sm:flex-row sm:items-end justify-between mb-8 sm:mb-12 gap-4'>
					<div>
						<div className='inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 border border-blue-100 text-blue-700 text-xs font-bold uppercase tracking-wider mb-2.5'>
							<ShoppingBag className='w-3.5 h-3.5 text-blue-600' />
							<span>Curated Catalog</span>
						</div>
						<h2 className='text-3xl sm:text-4xl font-black text-slate-900 tracking-tight'>
							Explore All Categories
						</h2>
						<p className='text-slate-500 text-sm sm:text-base mt-1.5 max-w-xl font-normal'>
							Each collection features handcrafted styles, multiple preview variants, and authentic tailoring.
						</p>
					</div>

					<div className='hidden sm:flex items-center gap-2 text-xs font-semibold text-slate-500'>
						<span>Hover cards to preview styles</span>
					</div>
				</div>

				{/* Responsive Grid with Staggered Visual Layout */}
				<div className='grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5 sm:gap-6'>
					{categories.map((category) => (
						<CategoryItem category={category} key={category.name} />
					))}
				</div>
			</section>

			{/* FEATURED PRODUCTS SECTION */}
			{products && products.length > 0 && (
				<div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-12'>
					<div className='border-t border-slate-200/80 pt-10'>
						<FeaturedProducts featuredProducts={products} />
					</div>
				</div>
			)}

			{/* CROSS-DEVICE SHOWCASE SECTION */}
			<section className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-14'>
				<div className='relative overflow-hidden rounded-3xl bg-gradient-to-br from-slate-900 via-slate-800 to-indigo-950 text-white shadow-2xl p-6 sm:p-10 lg:p-12 border border-slate-800'>
					<div className='grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center'>
						<div className='lg:col-span-5 space-y-4 sm:space-y-6'>
							<div className='inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/10 border border-blue-400/20 text-blue-300 text-xs font-semibold uppercase tracking-wider'>
								<Sparkles className='w-3.5 h-3.5 text-blue-400' />
								<span>Omnichannel Experience</span>
							</div>
							<h2 className='text-2xl sm:text-4xl font-black tracking-tight leading-tight'>
								Shop Seamlessly. <br />
								<span className='bg-gradient-to-r from-blue-400 via-indigo-300 to-purple-300 bg-clip-text text-transparent'>
									Web, Tablet & Mobile.
								</span>
							</h2>
							<p className='text-slate-300 text-sm sm:text-base leading-relaxed font-normal'>
								Enjoy an uninterrupted luxury shopping journey across all your devices. Your cart, wishlists, and curated recommendations stay effortlessly synchronized anywhere you go.
							</p>
							<div className='flex flex-wrap items-center gap-3 pt-2'>
								<a
									href='https://github.com/IsravelTECH/BuyBuddy/actions'
									target='_blank'
									rel='noopener noreferrer'
									className='inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 font-bold text-sm text-white shadow-lg shadow-blue-500/25 transition-all'
								>
									<span>Get Mobile App</span>
									<ArrowRight className='w-4 h-4' />
								</a>
								<button
									onClick={scrollToCategories}
									className='inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/10 hover:bg-white/15 font-semibold text-sm text-white border border-white/15 transition-all'
								>
									<span>Explore Collections</span>
								</button>
							</div>
						</div>

						<div className='lg:col-span-7 flex justify-center'>
							<div className='relative w-full rounded-2xl overflow-hidden shadow-2xl border border-white/10 group'>
								<img
									src='/showcase.jpg'
									alt='BuyBuddy on Desktop, Tablet, and Mobile'
									className='w-full h-auto object-cover transform group-hover:scale-[1.02] transition-transform duration-500'
								/>
							</div>
						</div>
					</div>
				</div>
			</section>
		</div>
	);
};

export default HomePage;
