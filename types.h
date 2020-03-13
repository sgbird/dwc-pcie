/**
 * Compute the number of elements of a variable length array.
 * <code>
 * const char *strs[] = { "a", "b", "c" };
 * unsigned num_strs = ARRAY_SIZE(strs);
 * </code>
 */
#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))


/**
 * Cast a member of a structure out to the containing structure.
 * @param ptr The pointer to the member.
 * @param type The type of the container struct this is embedded in.
 * @param member The name of the member within the struct.
 *
 * This is a mechanism which is used throughout the Linux kernel.
 */
#define container_of(ptr, type, member) ({			\
	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
	(type *)( (void *) ( (char *)__mptr - offsetof(type,member) ) );})


/**
 * Rounds @c m up to the nearest multiple of @c n using division.
 * @param m The value to round up to @c n.
 * @param n Round @c m up to a multiple of this number.
 * @returns The rounded integer value.
 */
#define DIV_ROUND_UP(m, n)	(((m) + (n) - 1) / (n))
