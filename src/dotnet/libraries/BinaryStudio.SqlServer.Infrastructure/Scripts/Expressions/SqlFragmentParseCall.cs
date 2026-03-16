using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ParseCall))]
    internal sealed class SqlFragmentParseCall : SqlFragmentPrimaryExpression<ParseCall>
        {
        #region ctor{IServiceProvider,ParseCall}
        public SqlFragmentParseCall(IServiceProvider context,ParseCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }