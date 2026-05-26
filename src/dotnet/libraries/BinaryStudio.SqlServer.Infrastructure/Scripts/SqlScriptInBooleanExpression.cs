using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlInBooleanExpression))]
    internal sealed class SqlScriptInBooleanExpression : SqlScriptBooleanExpression<SqlInBooleanExpression>
        {
        public Boolean HasNot { get { return Source.HasNot; }}

        #region ctor{IServiceProvider,SqlInBooleanExpression}
        public SqlScriptInBooleanExpression(IServiceProvider context,SqlInBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }