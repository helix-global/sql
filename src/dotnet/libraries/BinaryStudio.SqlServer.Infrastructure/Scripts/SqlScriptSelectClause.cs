using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlSelectClause))]
    internal sealed class SqlScriptSelectClause : SqlScriptCodeObject<SqlSelectClause>
        {
        public Boolean IsDistinct { get { return Source.IsDistinct; }}

        #region ctor{IServiceProvider,SqlSelectClause}
        public SqlScriptSelectClause(IServiceProvider context,SqlSelectClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }