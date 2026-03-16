using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ConvertCall))]
    internal sealed class SqlFragmentConvertCall : SqlFragmentPrimaryExpression<ConvertCall>
        {
        #region ctor{IServiceProvider,ConvertCall}
        public SqlFragmentConvertCall(IServiceProvider context,ConvertCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }