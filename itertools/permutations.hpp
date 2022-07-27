#pragma once

#ifndef ITERTOOLS_PERMUTATIONS_HPP_
#define ITERTOOLS_PERMUTATIONS_HPP_

#include <algorithm>
#include <cstddef>
#include <iterator>
#include <memory>
#include <numeric>
#include <type_traits>

namespace itertools
{

template<class Container>
class permutations_iterator
{
public:
	using iterator_category = std::input_iterator_tag;
	using difference_type = std::ptrdiff_t;
	using value_type = const typename Container::index_type*;
	using pointer = value_type*;
	using reference = value_type;

	using index_type = typename Container::index_type;

	class sentinel {};

	explicit permutations_iterator(Container& container) :
		m_container(container),
		m_i(0),
		m_exhausted(false)
	{
		index_type* const c = container.m_c.get();
		index_type* const a = container.m_a.get();
		const index_type n = container.m_n;

		std::fill(c, c + n, index_type{ 0 });
		std::iota(a, a + n, index_type{ 0 });
	}

	permutations_iterator& operator++()
	{
		index_type* const c = m_container.m_c.get();
		index_type* const a = m_container.m_a.get();

		while (m_i < m_container.m_n)
		{
			if (c[m_i] < m_i)
			{
				if (m_i % 2 == 0)
					std::swap(a[0], a[m_i]);
				else
					std::swap(a[c[m_i]], a[m_i]);

				++c[m_i];
				m_i = 0;

				return *this;
			}
			else
			{
				c[m_i] = 0;
				++m_i;
			}
		}

		m_exhausted = true;

		return *this;
	}

	reference operator*() const
	{
		return m_container.m_a.get();
	}

	friend bool operator==(const permutations_iterator& lhs, const sentinel&)
	{
		return lhs.m_exhausted;
	}

	friend bool operator!=(const permutations_iterator& lhs, const sentinel& rhs)
	{
		return !operator==(lhs, rhs);
	}

private:
	Container& m_container;
	index_type m_i;
	bool m_exhausted;
};

template<
	class IndexT,
	class = typename std::enable_if<std::is_unsigned<IndexT>::value>::type>
class permutations
{
public:
	using index_type = IndexT;
	using iterator = permutations_iterator<permutations<IndexT>>;

	explicit permutations(index_type n) :
		m_c(new index_type[n]),
		m_a(new index_type[n]),
		m_n(n)
	{
	}

	iterator begin()
	{
		return iterator(*this);
	}

	typename iterator::sentinel end() const
	{
		return typename iterator::sentinel();
	}

	index_type n() const
	{
		return m_n;
	}

	friend iterator;

private:
	std::unique_ptr<index_type[]> m_c;
	std::unique_ptr<index_type[]> m_a;
	index_type m_n;
};

}	// namespace itertools

#endif
