using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlCase : ISqlCase
        {
        public static readonly ISqlCase Lowercase = new SqlLowercase();
        public static readonly ISqlCase Uppercase = new SqlUppercase();

        private class SqlUppercase : SqlCase
            {
            #region M:ChangeCase(String):String
            public override String ChangeCase(String value)
                {
                return value?.ToUpperInvariant();
                }
            #endregion
            }

        private class SqlLowercase : SqlCase
            {
            #region M:ChangeCase(String):String
            public override String ChangeCase(String value)
                {
                return value?.ToLowerInvariant();
                }
            #endregion
            }

        private SqlCase()
            {
            }

        public abstract String ChangeCase(String value);
        }
    }