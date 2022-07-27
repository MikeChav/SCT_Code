#pragma once

#ifndef ITERTOOLS_COMBINATIONS_WITH_REPLACEMENT_HPP_
#define ITERTOOLS_COMBINATIONS_WITH_REPLACEMENT_HPP_

#include <algorithm>
#include <cstddef>
#include <iterator>
#include <memory>
#include <type_traits>

namespace itertools
{

template<class Container>
class combinations_with_replacement_iterator
{
public:
	using iterator_category = std::input_iterator_tag;
	using difference_type = std::ptrdiff_t;
	using value_type = const typename Container::index_type*;
	using pointer = value_type*;
	using reference = value_type;

	using index_type = typename Container::index_type;

	class sentinel {};

	explicit combinations_with_replacement_iterator(Container& container) :
		m_container(container),
		m_exhausted(!container.m_n && container.m_r)
	{
		index_type* const indices = container.m_indices.get();
		const std::size_t r = container.m_r;

		std::fill(indices, indices + r, index_type{ 0 });
	}

	combinations_with_replacement_iterator& operator++()
	{
		index_type* const indices = m_container.m_indices.get();
		const index_type n = m_container.m_n;
		const std::size_t r = m_container.m_r;

		std::size_t i = r;

		while (i > 0 && indices[i - 1u] == n - 1u)
			--i;

		if (i > 0)
		{
			const index_type index = indices[--i] + 1u;

			for (; i < r; ++i)
				indices[i] = index;
		}
		else
		{
			m_exhausted = true;
		}

		return *this;
	}

	reference operator*() const
	{
		return m_container.m_indices.get();
	}

	friend bool operator==(
		const combinations_with_replacement_iterator& lhs,
		const sentinel&)
	{
		return lhs.m_exhausted;
	}

	friend bool operator!=(
		const combinations_with_replacement_iterator& lhs,
		const sentinel& rhs)
	{
		return !operator==(lhs, rhs);
	}

private:
	Container& m_container;
	bool m_exhausted;
};

template<
	class IndexT,
	class = typename std::enable_if<std::is_unsigned<IndexT>::value>::type>
class combinations_with_replacement
{
public:
	using index_type = IndexT;
	using iterator = combinations_with_replacement_iterator<
		combinations_with_replacement<IndexT>>;

	combinations_with_replacement(index_type n, std::size_t r) :
		m_indices(new index_type[r]),
		m_n(n),
		m_r(r)
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

	std::size_t r() const
	{
		return m_r;
	}

	friend iterator;

private:
	std::unique_ptr<index_type[]> m_indices;
	index_type m_n;
	std::size_t m_r;
};

}	// namespace itertools

#endif
