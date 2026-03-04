using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptLikeBooleanExpression : SqlScriptBooleanExpression<SqlLikeBooleanExpression>
        {
        public Boolean HasNot {get{ return Source.HasNot; }}

        #region ctor{IServiceProvider,SqlLikeBooleanExpression}
        public SqlScriptLikeBooleanExpression(IServiceProvider context,SqlLikeBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }