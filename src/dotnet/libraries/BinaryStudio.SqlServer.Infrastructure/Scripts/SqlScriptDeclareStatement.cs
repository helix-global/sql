using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptDeclareStatement<T> : SqlScriptStatement<T>
        where T: SqlDeclareStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptDeclareStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }