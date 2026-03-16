using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlClrMethodSpecifier))]
    internal sealed class SqlScriptClrMethodSpecifier : SqlScriptClrClassSpecifier<SqlClrMethodSpecifier>
        {
        #region ctor{IServiceProvider,SqlClrMethodSpecifier}
        public SqlScriptClrMethodSpecifier(IServiceProvider context,SqlClrMethodSpecifier source)
            : base(context,source)
            {
            }
        #endregion
        }
    }