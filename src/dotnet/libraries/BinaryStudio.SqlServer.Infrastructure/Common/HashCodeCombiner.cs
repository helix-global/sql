using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal static class HashCodeCombiner
        {
        public static Int32 GetHashCode(Int32 h1,Int32 h2) { return (((h1 << 5) + h1) ^ h2); }
        public static Int32 GetHashCode(Int32 h1,Int32 h2,Int32 h3) { return GetHashCode(GetHashCode(h1,h2),h3); }
        public static Int32 GetHashCode(Int32 h1,Int32 h2,Int32 h3,Int32 h4) { return GetHashCode(GetHashCode(h1,h2),GetHashCode(h3,h4)); }
        public static Int32 GetHashCode(Int32 h1,Int32 h2,Int32 h3,Int32 h4,Int32 h5) { return GetHashCode(GetHashCode(h1,h2,h3,h4),h5); }
        public static Int32 GetHashCode(Int32 h1,Int32 h2,Int32 h3,Int32 h4,Int32 h5,Int32 h6) { return GetHashCode(GetHashCode(h1,h2,h3,h4),GetHashCode(h5,h6)); }
        public static Int32 GetHashCode(Int32 h1,Int32 h2,Int32 h3,Int32 h4,Int32 h5,Int32 h6,Int32 h7) { return GetHashCode(GetHashCode(h1,h2,h3,h4),GetHashCode(h5,h6,h7)); }
        public static Int32 GetHashCode(Int32 h1,Int32 h2,Int32 h3,Int32 h4,Int32 h5,Int32 h6,Int32 h7,Int32 h8) { return GetHashCode(GetHashCode(h1,h2,h3,h4),GetHashCode(h5,h6,h7,h8)); }
        public static Int32 GetHashCode(Object o) { return (o != null) ? o.GetHashCode() : 0; }
        public static Int32 GetHashCode(Object o1,Object o2) { return GetHashCode(GetHashCode(o1),GetHashCode(o2)); }
        public static Int32 GetHashCode(Object o1,Object o2,Object o3) { return GetHashCode(GetHashCode(o1,o2),o3); }
        public static Int32 GetHashCode(Object o1,Object o2,Object o3,Object o4) { return GetHashCode(GetHashCode(o1,o2),GetHashCode(o3,o4)); }
        public static Int32 GetHashCode(Object o1,Object o2,Object o3,Object o4,Object o5) { return GetHashCode(GetHashCode(o1,o2),GetHashCode(o3,o4),GetHashCode(o5)); }
        public static Int32 GetHashCode(Object o1,Object o2,Object o3,Object o4,Object o5,Object o6) { return GetHashCode(GetHashCode(o1,o2),GetHashCode(o3,o4),GetHashCode(o5,o6)); }
        }
    }
