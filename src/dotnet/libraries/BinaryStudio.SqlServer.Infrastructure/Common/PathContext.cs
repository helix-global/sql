using System;
using System.Linq;
using System.Text.RegularExpressions;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class PathContext
        {
        public String[] values = new String[0];
        public PathContext(String path) {
            if (!String.IsNullOrWhiteSpace(path)) {
                values = path.Split(new []{'/','\\' }, StringSplitOptions.RemoveEmptyEntries).Select(i => i.Trim()).ToArray();
                }
            }

        /// <summary>Returns the file name and extension of the specified path context.</summary>
        /// <returns>The string after the last directory separator character in context.</returns>
        public String GetFileName() {
            if (values.Length == 0) { return String.Empty; }
            if (values.Length == 1) {
                return Regex.IsMatch(values[0],@"[A-Za-z][:]")
                    ? String.Empty
                    : values[0];
                }
            return values[values.Length - 1];
            }

        /// <summary>Returns the file name and extension of the specified path string.</summary>
        /// <param name="path">The path string from which to obtain the file name and extension.</param>
        /// <returns> If the last character of path is a directory or volume separator character, this method returns <see cref="String.Empty"/>. If path is <see langword="null"/>, this method returns <see langword="null"/>.</returns>
        public static String GetFileName(String path) {
            return (path != null)
                ? new PathContext(path).GetFileName()
                : null;
            }
        }
    }
