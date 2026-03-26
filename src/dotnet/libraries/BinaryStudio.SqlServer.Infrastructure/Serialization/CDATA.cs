using System;
using System.Collections.Generic;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class CDATA
        {
        public IList<String> Values { get; }
        public CDATA(String source) {
            Values = source.Split(new []{ "\n" },StringSplitOptions.None).
                Select(i => i.TrimEnd('\r').TrimEnd()).
                ToArray();
            }

        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return String.Join(Environment.NewLine,Values);
            }

        public static explicit operator CDATA(String source) {
            return !String.IsNullOrWhiteSpace(source)
                ? new CDATA(source)
                : null;
            }
        }
    }
